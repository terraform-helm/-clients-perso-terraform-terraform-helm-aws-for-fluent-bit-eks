locals {
  eks_oidc_issuer_url   = var.oidc_provider != null ? var.oidc_provider : replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
  eks_oidc_provider_arn = "arn:${data.aws_partition.this.partition}:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
}

data "aws_partition" "this" {}
data "aws_caller_identity" "this" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_id
}

data "aws_iam_policy_document" "fluentbit" {
  statement {
    sid       = "PutLogEvents"
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.this.partition}:logs:${var.region}:${data.aws_caller_identity.this.account_id}:log-group:*:log-stream:*"]
    actions   = ["logs:PutLogEvents"]
  }

  statement {
    sid       = "CreateCWLogs"
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.this.partition}:logs:${var.region}:${data.aws_caller_identity.this.account_id}:log-group:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    principals {
      type        = "Federated"
      identifiers = [local.eks_oidc_provider_arn]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test     = "StringLike"
      variable = "${local.eks_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:${var.kubernetes_namespace}:${var.service_account_name}"]
    }
    condition {
      test     = "StringLike"
      variable = "${local.eks_oidc_issuer_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

module "iam" {
  source                        = "github.com/terraform-helm/terraform-aws-iam-role"
  iam_role_name                 = var.irsa_iam_role_name
  iam_role_description          = "AWS IAM Role for the Kubernetes service account ${var.service_account_name}."
  iam_role_assume_role_policy   = data.aws_iam_policy_document.assume_role_policy.json
  iam_role_permissions_boundary = var.irsa_iam_permissions_boundary
  iam_role_path                 = var.irsa_iam_role_path
  iam_policy_name               = var.irsa_iam_policy_name
  iam_policy_description        = "IAM Policy for AWS for FluentBit"
  iam_policy_policy             = data.aws_iam_policy_document.fluentbit.json
}

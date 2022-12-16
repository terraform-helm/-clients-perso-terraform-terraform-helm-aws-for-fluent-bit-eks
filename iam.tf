data "aws_partition" "this" {}
data "aws_caller_identity" "this" {}

data "aws_iam_policy_document" "this" {
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

module "role_sa" {
  source        = "github.com/littlejo/terraform-aws-role-eks.git?ref=v0.1"
  name          = var.irsa_iam_role_name
  inline_policy = data.aws_iam_policy_document.this.json
  cluster_id    = var.cluster_id
  create_sa     = true
  service_accounts = {
    main = {
      name      = var.service_account_name
      namespace = var.kubernetes_namespace
    }
  }
}

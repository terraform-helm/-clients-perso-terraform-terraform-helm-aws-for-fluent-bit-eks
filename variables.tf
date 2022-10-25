variable "images" {
  description = "Map of images"
  type        = map(string)
  default     = {}
}

variable "install_helm" {
  description = "Do you want to install helm chart?"
  type        = bool
  default     = true
}

variable "release_version" {
  description = "version of helm release"
  type        = string
  default     = null
}

variable "service_account_name" {
  description = "Name of the service account to have right to send to CloudWatch logs"
  type        = string
  default     = "aws-for-fluent-bit-sa"
}

variable "kubernetes_svc_image_pull_secrets" {
  description = "Secrets to pull your image"
  type        = list(any)
  default     = null
}

variable "kubernetes_namespace" {
  description = "Namespace to install autoscaler pod"
  type        = string
  default     = "logging"
}

variable "irsa_iam_role_name" {
  type        = string
  description = "IAM role name for IRSA"
  default     = "eks-fluentbit"
}

variable "irsa_iam_policy_name" {
  type        = string
  description = "IAM policy name for IRSA"
  default     = "eks-fluentbit"
}

variable "irsa_iam_permissions_boundary" {
  description = "IAM permissions boundary for IRSA roles"
  type        = string
  default     = ""
}

variable "irsa_iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "cluster_id" {
  description = "EKS cluster name"
  type        = string
}

variable "region" {
  description = "Region of you eks cluster"
  type        = string
}

variable "oidc_provider" {
  description = "EKS OIDC provider"
  type        = string
  default     = null
}

variable "values" {
  description = "Values of helm"
  type        = list(any)
  default     = []
}

variable "loggroup_name" {
  description = "Log group name"
  type        = string
}

module "helm" {
  source          = "github.com/terraform-helm/terraform-helm-aws-for-fluent-bit"
  count           = var.install_helm ? 1 : 0
  release_version = var.release_version
  images          = var.images
  set_values = [
    {
      name  = "serviceAccount.name"
      value = var.service_account_name
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "cloudWatch.logGroupName"
      value = var.loggroup_name
    }
  ]
  values = var.values
}

module "iam_role" {
  source        = "git@gitlab.com:freetech_solutions_terraform/tf-aws-iam-role-common.git"
  iam_role_name = var.tags["role"]
}


locals {
  region     = "eu-west-1"
  account_id = data.aws_caller_identity.current.account_id

  github_token          = ""
  github_owner          = "FoxyCart"
  github_repo           = "foxy-terraform-n8n"
  github_branch         = "main"
  github_connection_arn = "arn:aws:codestar-connections:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:connection/3ae37301-f985-48b7-8c5b-a109e85a13c5"

  common_tags = {
    "CreatedBy"   = var.source_repository
    "Environment" = var.environment

  }
}

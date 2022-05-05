locals {
  region     = data.aws_region.current.id
  account_id = data.aws_caller_identity.current.account_id

  github_token          = ""
  github_owner          = "FoxyCart"
  github_repo           = "foxy-terraform-n8n"
  github_branch         = "main"
  github_connection_arn = "arn:aws:codestar-connections:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:connection/70bdea3c-168b-433c-84d4-969b6a47a21c"

  command_tags = {
    "CreatedBy"   = var.source_repository
    "Environment" = var.environment

  }
}

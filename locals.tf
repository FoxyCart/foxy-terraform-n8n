locals {
  region     = data.aws_region.current.id
  account_id = data.aws_caller_identity.current.account_id

  github_token          = ""
  github_owner          = "FoxyCart"
  github_repo           = "foxy-terraform-n8n"
  github_branch         = "main"
  github_connection_arn = "arn:aws:codestar-connections:us-west-2:185203724531:connection/07715bf4-4124-470c-84cb-35649be1fb84"

  common_tags = {
    "CreatedBy"   = var.source_repository
    "Environment" = var.environment

  }
}

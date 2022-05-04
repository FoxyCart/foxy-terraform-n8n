locals {
  command_tags = {
    "CreatedBy"   = var.source_repository
    "Environment" = var.environment

  }
}

################################################################################
resource "aws_ecr_repository" "n8n_ecr" {
  name                 = "${var.environment}-n8n-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }


  tags = merge(local.common_tags, {})
}


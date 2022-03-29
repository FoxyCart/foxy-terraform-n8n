################################################################################
resource "aws_cloudwatch_log_group" "ecs_cluster_log_group" {
  name              = "${var.environment}-n8n-log-group"
  retention_in_days = 60
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name               = "${var.environment}-n8n-cluster"
  capacity_providers = ["FARGATE"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_cluster_log_group.name
      }
    }
  }
}

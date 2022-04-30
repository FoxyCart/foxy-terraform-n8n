module "s3_bucket_code_build" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "code-build-s3-bucket-${random_id.random_id.hex}"
  acl    = "private"

  versioning = {
    enabled = true
  }

}


# CodeBuild
resource "aws_codebuild_project" "n8n_codebuild_project" {
  name          = "build-n8n-container"
  description   = "lorem ipsum"
  build_timeout = 60
  service_role  = module.codebuild_admin_iam_assumable_role.iam_role_arn

  artifacts {
    type = "NO_ARTIFACTS"
    #type     = "S3"
    #location = module.s3_bucket_code_build.s3_bucket_id
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.id
      type  = "PLAINTEXT"

    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = split("/", aws_ecr_repository.n8n_ecr.arn)[1]
      type  = "PLAINTEXT"

    }

    environment_variable {
      name  = "ECS_SERVICE_NAME"
      value = module.ecs-fargate.service_name
      type  = PLAINTEXT
    }


  }

  source {
    buildspec       = file("${path.module}/buildspec.yml")
    type            = "GITHUB"
    location        = "https://github.com/msharma24/foxy-terraform-n8n.git"
    git_clone_depth = 1
  }

  logs_config {
    cloudwatch_logs {
      group_name = module.codebuild_log_group.cloudwatch_log_group_name
    }
  }

}

module "codebuild_log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "3.0.0"

  name              = "codebuild_log_group_${random_id.random_id.hex}"
  retention_in_days = 7

}

# Code pipeline


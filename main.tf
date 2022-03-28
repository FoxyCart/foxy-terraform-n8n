# Set up providers
provider "aws" {
  region  = var.region
}

# The above is the default provider.
# This one's for when we need us-east-1, like for CloudFront certs.
# https://www.terraform.io/docs/configuration/providers.html
provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
}



# ==========================================================
# Networking
# ==========================================================
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.NameTag}-${var.Environment}-vpc"
  cidr = "${var.vpc_cidr_block}"

  azs             = [var.az_1, var.az_2]
  private_subnets = [var.aws_public1_cidr_block, var.aws_public2_cidr_block]
  public_subnets  = [var.aws_private1_cidr_block, var.aws_private2_cidr_block]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    CreatedBy = "https://github.com/FoxyCart/foxy-terraform-n8n"
    Environment = var.Environment
  }
}

# module "alb" {}
# module "cloudfront" {} # optional


# ==========================================================
# Databases
# ==========================================================
# module "mysql" {} # Aurora MySQL cluster
# module "redis" {} # ElastiCache Redis (cluster-mode enabled)


# ==========================================================
# ECS
# ==========================================================
# module "" {} # ECS, Services, Tasks, etc., in one or many modules


# ==========================================================
# CI/CD
# ==========================================================
# module "" {} # CodePipeline, CodeBuild, CodeDeploy, etc., in one or many modules
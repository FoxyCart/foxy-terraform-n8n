################################################################################
# VPC Module
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"


  name = "${var.environment}vpc"
  cidr = var.vpc_cidr

  azs              = ["${var.region}a", "${var.region}b"]
  private_subnets  = var.private_subnet_cidr_list
  public_subnets   = var.public_subnet_cidr_list
  database_subnets = var.databse_subnet_cidr_list

  enable_ipv6             = false
  create_igw              = true
  map_public_ip_on_launch = false

  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc"
  }

  private_subnet_tags = {

    Name = "vpc-private-subnet"
  }
  public_subnet_tags = {

    Name = "vpc-workload-subnet"
  }
}

################################################################################
# VPC Module Spoke VPC  - SSM Endpoint
################################################################################
module "vpc_ssm_endpoint" {

  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  vpc_id = module.vpc.vpc_id

  security_group_ids = [module.vpc.default_security_group_id]
  endpoints = {
    s3 = {
      service    = "s3"
      subnet_ids = module.vpc.private_subnets
      tags       = { Name = "vpc-s3-vpc-endpoint" }
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "vpc-ssm-vpc-endpoint" }
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true,
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "vpc-ssmmessages-vpc-endpoint" }
    },
    ec2messages = {
      service             = "ec2messages",
      private_dns_enabled = true,
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "vpc-ec2messages-vpc-endpoint" }
    },
    efs = {
      service             = "elasticfilesystem",
      private_dns_enabled = true,
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "vpc-efs-vpc-endpoint" }
    }
  }
}

# # Has to be a Gateway for S3
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id          = module.vpc.vpc_id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = module.vpc.private_route_table_ids
  tags = {
    Name = "vpc-s3-gateway-vpc-endpoint"
  }
}

################################################################################
# VPC Module
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"


  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs              = ["${var.region}a", "${var.region}b"]
  private_subnets  = var.private_subnet_cidr_list
  public_subnets   = var.public_subnet_cidr_list
  database_subnets = var.database_subnet_cidr_list

  enable_ipv6             = false
  create_igw              = true
  map_public_ip_on_launch = false

  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = merge(local.common_tags, {})

  private_subnet_tags = {

    Name = "vpc-private-subnet"
  }
  public_subnet_tags = {

    Name = "vpc-workload-subnet"
  }

  database_subnet_tags = {
    Name = "vpc-database-subnet"
  }
}

################################################################################
# VPC Module Spoke VPC  - SSM Endpoint
################################################################################
module "vpc_ssm_endpoint" {

  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.0.0"

  vpc_id = module.vpc.vpc_id

  security_group_ids = [module.vpc.default_security_group_id]
  endpoints = {
    s3 = {
      service    = "s3"
      subnet_ids = module.vpc.private_subnets
      tags       = merge(local.common_tags, { Name = "vpc-s3-endpoint" })
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = merge(local.common_tags, { Name = "vpc-ssm-endpoint" })
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true,
      subnet_ids          = module.vpc.private_subnets
      tags                = merge(local.common_tags, { Name = "vpc-ssm-messages-endpoint" })
    },
    ec2messages = {
      service             = "ec2messages",
      private_dns_enabled = true,
      subnet_ids          = module.vpc.private_subnets
      tags                = merge(local.common_tags, { Name = "vpc-ssm-ec2-messages-endpoint" })
    },
    efs = {
      service             = "elasticfilesystem",
      private_dns_enabled = true,
      subnet_ids          = module.vpc.private_subnets
      tags                = merge(local.common_tags, { Name = "vpc-ssm-efs-endpoint" })
    }
  }
}

# # Has to be a Gateway for S3
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id          = module.vpc.vpc_id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = module.vpc.private_route_table_ids

  tags = merge(local.common_tags, {
    Name = "vpc-s3-gateway-vpc-endpoint"
  })
}


################################################################################
# MySQL Aurora 
################################################################################
resource "random_password" "aurora_mysql_master_password" {
  length           = 24
  special          = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  override_special = "$"
}


################################################################################

resource "aws_secretsmanager_secret" "aurora_secretmanager_secret" {
  name = "${var.environment}-aurora-rds-secret-manager-${random_id.random_id.hex}"
}


resource "aws_secretsmanager_secret_version" "aurora_secretmanager_secret_value" {
  secret_id     = aws_secretsmanager_secret.aurora_secretmanager_secret.id
  secret_string = random_password.aurora_mysql_master_password.result
}


resource "aws_ssm_parameter" "aurora_ssm_parameter" {
  name        = "/${var.environment}/AURORAMYSQL/MasterPassword"
  description = "Aurora MySQL cluster master password"
  type        = "SecureString"
  value       = random_password.aurora_mysql_master_password.result

  tags = merge(local.common_tags, {
    "Name" = format("%s-ssm-paramter", var.environment)
  })
}

# ################################################################################
module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 6.0"

  name           = "${var.environment}-rds-db"
  engine         = var.aurora_engine
  database_name  = var.db_name
  engine_version = var.aurora_engine_version
  instances = {
    1 = {
      identifier          = "${var.db_name}-${var.environment}-rds"
      publicly_accessible = false
      instance_class      = var.aurora_instance_class
    }
  }

  vpc_id                 = module.vpc.vpc_id
  create_db_subnet_group = false
  db_subnet_group_name   = module.vpc.database_subnet_group_name

  create_security_group  = false
  vpc_security_group_ids = [module.mysql_security_group.security_group_id]

  iam_database_authentication_enabled = true
  create_random_password              = false
  master_password                     = random_password.aurora_mysql_master_password.result
  master_username                     = "admin"

  db_parameter_group_name         = aws_db_parameter_group.db_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db_parameter_group.id

  preferred_maintenance_window = var.aurora_maintenance_window
  preferred_backup_window      = var.aurora_backup_window
  backup_retention_period      = 7

  create_monitoring_role = false
  monitoring_interval    = var.monitoring_interval
  monitoring_role_arn    = aws_iam_role.db_monitoring_role.arn

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  deletion_protection             = false #set to true for Production
  apply_immediately               = true
  skip_final_snapshot             = true

  tags = merge(local.common_tags, {})
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "${var.environment}-aurora-57-db-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${var.environment}-aurora-57-db-parameter-group"

  tags = merge(local.common_tags, {})
}

resource "aws_rds_cluster_parameter_group" "db_parameter_group" {
  name        = "${var.environment}-aurora-57-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${var.environment}-aurora-57-cluster-parameter-group"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  tags = merge(local.common_tags, {})
}


resource "aws_iam_role" "db_monitoring_role" {
  description = "DB Monitoring Role"
  name        = "db_monitoring_role-${random_id.random_id.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
  managed_policy_arns = [aws_iam_policy.rds_monitoring_policy.arn]
  tags = merge(local.common_tags, {
  })
}

resource "aws_iam_policy" "rds_monitoring_policy" {
  name = "rds_monitoring_policy-${random_id.random_id.hex}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "EnableCreationAndManagementOfRDSCloudwatchLogGroups",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:PutRetentionPolicy"
        ],
        "Resource" : [
          "arn:aws:logs:*:*:log-group:RDS*"
        ]
      },
      {
        "Sid" : "EnableCreationAndManagementOfRDSCloudwatchLogStreams",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents"
        ],
        "Resource" : [
          "arn:aws:logs:*:*:log-group:RDS*:log-stream:*"
        ]
      }
    ]
  })
  tags = merge(local.common_tags, {
  })

}



################################################################################
# Elastic Cache Cluster  - Redis
################################################################################
module "redis" {
  source  = "umotif-public/elasticache-redis/aws"
  version = "3.0.0"

  name_prefix        = "${var.environment}-redis-cluster"
  num_cache_clusters = 2
  node_type          = "cache.t3.small"

  cluster_mode_enabled    = true
  replicas_per_node_group = 1
  num_node_groups         = 2

  engine_version           = "6.x"
  port                     = 6379
  maintenance_window       = "mon:03:00-mon:04:00"
  snapshot_window          = "04:00-06:00"
  snapshot_retention_limit = 7

  automatic_failover_enabled = true

  at_rest_encryption_enabled = false
  transit_encryption_enabled = false

  apply_immediately = true
  family            = "redis6.x"
  description       = "Alpha Build elasticache redis."

  subnet_ids = module.vpc.database_subnets
  vpc_id     = module.vpc.vpc_id

  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]

  parameter = [
    {
      name  = "repl-backlog-size"
      value = "16384"
    }
  ]

  tags = merge(local.common_tags, {
  })
}


################################################################################
# Application Load Balancer 
################################################################################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.8.0"

  name               = "${var.environment}-public-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups = [
    module.alb_security_group.security_group_id
  ]

  tags = merge(local.common_tags, {})

}

resource "aws_lb_listener" "alb_80" {
  load_balancer_arn = module.alb.lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.ecs-fargate.target_group_arn[0]
  }

  tags = merge(local.common_tags, {})
}



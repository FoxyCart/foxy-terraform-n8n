# GENERAL SETTINGS
region = "eu-west-1"
az_1   = "eu-west-1a"
az_2   = "eu-west-1b"

NameTag     = "foxy-n8n"
Environment = "dev"


# VPC & NETWORKING
vpc_cidr_block = "10.50.0.0/16"
aws_public1_cidr_block = "10.50.0.0/24"
aws_public2_cidr_block = "10.50.1.0/24"
aws_private1_cidr_block = "10.50.100.0/24"
aws_private2_cidr_block = "10.50.101.0/24"


# MySQL
mysql_db_name       = ""
mysql_db_user       = ""
mysql_db_password   = ""
mysql_instance_type = "db.t3.small"


# REDIS
redis_node_type      = "cache.t3.micro"
redis_replicas_per_node_group = 0 # 0 for dev is ok.
redis_num_node_groups = 3 # Minimum 3
redis_engine_version = "6.x" # This is to create it in the first place
# redis_engine_version = "6.0.5" # This is for applys


# ECS & FARGATE
ecs_desired_count = 1
ecs_maximum_count = 3
ecs_deployment_minimum_healthy_percent = 100
ecs_task_cpu      = "1024"
ecs_task_memory   = "2048"

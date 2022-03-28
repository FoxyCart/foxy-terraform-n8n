variable "NameTag" {}
variable "Environment" {}

variable "region" {}
variable "az_1" {}
variable "az_2" {}

variable "vpc_cidr_block" {}
variable "aws_public1_cidr_block" {}
variable "aws_public2_cidr_block" {}
variable "aws_private1_cidr_block" {}
variable "aws_private2_cidr_block" {}


# MySQL
variable "mysql_db_name" {}
variable "mysql_db_user" {}
variable "mysql_db_password" {}
variable "mysql_instance_type" {}


# REDIS
variable "redis_node_type" {}
variable "redis_replicas_per_node_group" {}
variable "redis_num_node_groups" {}
variable "redis_engine_version" {}


# ECS & FARGATE
variable "ecs_desired_count" {}
variable "ecs_maximum_count" {}
variable "ecs_deployment_minimum_healthy_percent" {}
variable "ecs_task_cpu" {}
variable "ecs_task_memory" {}

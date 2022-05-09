module "ecs-fargate" {
  source  = "umotif-public/ecs-fargate/aws"
  version = "~> 6.1.0"

  name_prefix                       = "ecs-fargate-n8n"
  vpc_id                            = module.vpc.vpc_id
  private_subnet_ids                = module.vpc.private_subnets
  health_check_grace_period_seconds = 300
  desired_count                     = 1

  cluster_id = aws_ecs_cluster.ecs_cluster.id

  #task_container_image = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${aws_ecr_repository.n8n_ecr.name}:latest"
  task_container_image   = "n8nio/n8n:latest"
  task_definition_cpu    = 256
  task_definition_memory = 512
  load_balanced          = true


  task_container_port             = 5678
  task_container_assign_public_ip = false

  health_check = {
    matcher = "200-401"
    port    = "traffic-port"
    path    = "/setup"
  }

  target_groups = [
    {
      target_group_name = "ecs-fargate-n8n-tg"
      container_port    = 5678

    }
  ]

  task_container_environment = {

    # aurora mysql env vars
    DB_TYPE             = "mysqldb"
    DB_MYSQLDB_DATABASE = var.db_name
    DB_MYSQLDB_HOST     = module.aurora.cluster_endpoint
    DB_MYSQLDB_PORT     = module.aurora.cluster_port
    DB_MYSQLDB_USER     = "admin"
    DB_MYSQLDB_PASSWORD = random_password.aurora_mysql_master_password.result

    # elasticache redis env vars
    QUEUE_BULL_PREFIX                  = "n8n"
    QUEUE_BULL_REDIS_DB                = "0"
    QUEUE_BULL_REDIS_HOST              = module.redis.elasticache_replication_group_primary_endpoint_address
    QUEUE_BULL_REDIS_PORT              = module.redis.elasticache_port
    QUEUE_BULL_REDIS_TIMEOUT_THRESHOLD = "1000" #seconds
    QUEUE_RECOVERY_INTERVAL            = "60"   #seconds



  }


  tags = merge(local.common_tags, {})

  depends_on = [
    module.alb,
    module.redis
  ]


}

resource "aws_security_group_rule" "sg_rule_ecs" {
  security_group_id = module.ecs-fargate.service_sg_id
  type              = "ingress"
  from_port         = 5678
  to_port           = 5678
  protocol          = "tcp"
  #cidr_blocks       = [module.vpc.vpc_cidr_block]
  source_security_group_id = module.alb_security_group.security_group_id


}

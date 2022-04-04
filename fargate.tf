module "ecs-fargate" {
  source  = "umotif-public/ecs-fargate/aws"
  version = "~> 6.1.0"

  name_prefix                       = "ecs-fargate-n8n"
  vpc_id                            = module.vpc.vpc_id
  private_subnet_ids                = module.vpc.private_subnets
  health_check_grace_period_seconds = 300
  desired_count                     = 1

  cluster_id = aws_ecs_cluster.ecs_cluster.id

  task_container_image   = "n8nio/n8n:latest"
  task_definition_cpu    = 256
  task_definition_memory = 512
  load_balanced          = true


  task_container_port             = 5678
  task_container_assign_public_ip = false

  health_check = {
    port = "traffic-port"
    path = "/"
  }

  target_groups = [
    {
      target_group_name = "ecs-fargate-example"
      container_port    = 5678

    }
  ]


  tags = {
    Environment = "test"
    Project     = "Test"
  }

  depends_on = [
    module.alb
  ]
}











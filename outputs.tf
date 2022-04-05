output "vpc_id" {
  value = module.vpc.vpc_id

}

output "aurora_cluster_arn" {
  value = module.aurora.cluster_arn
}

output "tg" {
  value = module.ecs-fargate.target_group_arn[0]

}

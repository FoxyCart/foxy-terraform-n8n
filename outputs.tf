output "vpc_id" {
  value = module.vpc.vpc_id

}

output "aurora_cluster_arn" {
  value = module.aurora.cluster_arn
}

output "target_group_arn" {
  value = module.ecs-fargate.target_group_arn[0]

}

output "ecr_name" {
  value = split("/", aws_ecr_repository.n8n_ecr.arn)[1]

}

output "redis_primary" {
  description = "Redis Primary"
  value       = module.redis.elasticache_replication_group_primary_endpoint_address

}

module "mysql_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/mysql"
  version = "4.3.0"

  name        = "${var.environment}-mysql-sg"
  description = "Security group with MySQL/Aurora using port 3306"
  vpc_id      = module.vpc.vpc_id

  auto_ingress_with_self = []
  ingress_cidr_blocks    = [module.vpc.vpc_cidr_block]
}


module "redis_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/redis"
  version = "4.3.0"

  name        = "${var.environment}-redis-sg"
  description = "Security group with ElasitCache redis  using port 6379"
  vpc_id      = module.vpc.vpc_id

  auto_ingress_with_self = []
  ingress_cidr_blocks    = [module.vpc.vpc_cidr_block]

  # ingress_with_source_security_group_id = [
  #   # ECS Container SG Security Group IP
  # ]
}

# Set up providers
provider "aws" {
  region = var.region
}
# Configure the MySQL provider based on the outcome of
# creating the aws_db_instance.
provider "mysql" {
  endpoint = module.aurora.cluster_endpoint
  username = "admin"
  password = random_password.aurora_mysql_master_password.result
}



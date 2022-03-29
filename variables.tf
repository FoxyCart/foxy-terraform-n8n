variable "environment" {
  description = "AWS Environment name"
  default     = "dev"

}
variable "region" {}

variable "vpc_cidr" {
  description = "AWS VPC CIDR Range"
  default     = "10.0.0.0/16"

}

variable "private_subnet_cidr_list" {
  description = "List of Private Subnet CIDR"
  default     = ["10.0.1.0/24", "10.0.2.0/24", ]

}

variable "public_subnet_cidr_list" {
  description = "List of Public Subnet CIDR"
  default     = ["10.0.101.0/24", "10.0.102.0/24", ]

}

variable "database_subnet_cidr_list" {
  description = "List of Databse Subnet CIDR"
  default     = ["10.0.3.0/24", "10.0.103.0/24"]


}

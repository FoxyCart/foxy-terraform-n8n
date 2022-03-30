variable "environment" {
  description = "AWS Environment name"
  default     = "dev"

}
variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_cidr" {
  description = "AWS VPC CIDR Range"
  type        = string
  default     = "10.0.0.0/16"

}

variable "private_subnet_cidr_list" {
  description = "List of Private Subnet CIDR"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", ]

}

variable "public_subnet_cidr_list" {
  description = "List of Public Subnet CIDR"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", ]

}

variable "database_subnet_cidr_list" {
  description = "List of Databse Subnet CIDR"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.103.0/24"]


}


################################################################################
# RDS Vars
################################################################################

variable "db_name" {
  description = "Required. Name of the RDS database instance"
  type        = string
}

variable "aurora_engine_version" {
  description = "Database engine version"
  default     = "5.7.34"
  type        = string
}


variable "aurora_instance_class" {
  description = "Instance class for the database"
  default     = "db.t2.small"
  type        = string
}

variable "aurora_engine" {
  description = "The database engine type"
  type        = string
  default     = "mysql"
}


variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  default     = 5
  type        = number
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting  Enhanced Monitoring metrics, specify 0. The default is 30.  Valid Values: 0, 1, 5, 10, 15, 30, 60."
  default     = "30"
  type        = string
}

variable "aurora_maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
  default     = "Mon:12:00-Mon:15:00"
  type        = string
}

variable "aurora_backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
  default     = "15:00-17:00"
  type        = string
}

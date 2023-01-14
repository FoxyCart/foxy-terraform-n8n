terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.8.0"
    }

    mysql = {
      source  = "winebarrel/mysql"
      version = "~> 1.10.2"
    }
  }
}

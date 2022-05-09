data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


# lookup latest AL2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "amzn2-ami-hvm*"
}


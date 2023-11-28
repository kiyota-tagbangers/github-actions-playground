locals {
  name_tag = "kiyota-codedeploy-test"
}

# VPC
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = local.name_tag
  cidr = "10.0.0.0/16"

  azs = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Name = local.name_tag
  }
}

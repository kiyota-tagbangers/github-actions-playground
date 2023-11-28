terraform {
  required_version = "~> 1.5.0"
  required_providers {
    aws = {
      version = "~> 5.13.0"
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    # 先に GUI でつくっておく
    bucket = "kiyota-codedeploy-test-tf-state"
    key    = "terraform.tfstate"
  }
}

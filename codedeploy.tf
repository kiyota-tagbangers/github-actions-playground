# Jar ファイルを保管する S3 バケット
resource "aws_s3_bucket" "app_jar" {
  bucket        = join("-", [local.name_tag, "app", "jar"])
  force_destroy = true
}

# Code Deploy Revision を管理する S3 バケット
resource "aws_s3_bucket" "codedeploy_revision" {
  bucket        = join("-", [local.name_tag, "codedeploy", "revision"])
  force_destroy = true
}

# Code Deploy サービスロール
data "aws_iam_policy_document" "codedeploy_service_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codedeploy_service_role" {
  name               = "${local.name_tag}-service-role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_service_role.json
}

resource "aws_iam_role_policy_attachment" "codedeploy_service_role" {
  role       = aws_iam_role.codedeploy_service_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_app" "app" {
  compute_platform = "Server"
  name             = local.name_tag
}

resource "aws_codedeploy_deployment_group" "ec2" {
  app_name               = aws_codedeploy_app.app.name
  deployment_group_name  = local.name_tag
  service_role_arn       = aws_iam_role.codedeploy_service_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  # EC2 がマッチする条件を指定
  ec2_tag_filter {
    key   = "Name"
    type  = "KEY_AND_VALUE"
    value = local.name_tag
  }
}

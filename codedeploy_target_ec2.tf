# Security Group
resource "aws_security_group" "ec2" {
  name   = local.name_tag
  vpc_id = module.vpc.vpc_id

  # Code Deploy Agent は Port:443 を経由して HTTPS でアウトバウンドの通信をおこなう
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = local.name_tag
  }
}

# Red Hat Enterprise Linux の AMI
# 9.x は CodeDeploy Agent のサポート対象外です
# https://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-agent.html
data "aws_ami" "redhat_linux" {
  most_recent = true
  # Red Hat
  # https://access.redhat.com/ja/solutions/274443
  owners = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-7.9_HVM-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 にアタッチする Code Deploy Agent 向けのポリシー
# https://docs.aws.amazon.com/ja_jp/codedeploy/latest/userguide/getting-started-create-iam-instance-profile.html
data "aws_iam_policy_document" "codedeploy_s3" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]
    resources = [
      "${aws_s3_bucket.codedeploy_revision.arn}/*",
      "${aws_s3_bucket.app_jar.arn}/*",
      "arn:aws:s3:::aws-codedeploy-ap-northeast-1/*",
    ]
  }
}

resource "aws_iam_policy" "codedeploy_s3" {
  name   = "${local.name_tag}-codedeploy-s3"
  policy = data.aws_iam_policy_document.codedeploy_s3.json
}

# EC2
# https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
# /var/run/sampleapp のディレクトリが存在する
module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.3.1"

  ami                         = data.aws_ami.redhat_linux.image_id
  associate_public_ip_address = true
  availability_zone           = "ap-northeast-1a"
  create_iam_instance_profile = true
  iam_role_name               = local.name_tag
  iam_role_policies = {
    AmazonSSMManagedEC2InstanceDefaultPolicy = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
    CodeDeployS3Policy                       = aws_iam_policy.codedeploy_s3.arn
  }
  instance_type = "t3.micro"
  name          = local.name_tag
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.ec2.id,
  ]
  instance_tags = {
    Name   = local.name_tag
    Status = "Active"
  }
  user_data = <<-USERDATA
  #!/bin/bash
  # setup ssm-agent
  yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

  # setup awscli
  yum install -y python3
  yum install -y python3-pip
  pip3 install awscli

  # user add
  useradd batch-sample

  # setup codedeploy-agent
  yum install -y ruby
  curl https://aws-codedeploy-ap-northeast-1.s3.ap-northeast-1.amazonaws.com/latest/install -O
  # https://repost.aws/questions/QUgNz4VGCFSC2TYekM-6GiDQ/dnf-yum-both-fails-while-being-executed-on-instance-bootstrap-on-amazon-linux-2023
  # RPM: error: can't create transaction lock on /var/lib/rpm/.rpm.lock (Resource temporarily unavailable)
  sleep 30
  chmod +x ./install
  ./install auto
  rm -f ./install

  # setup java
  yum install -y java

  # mk app dir
  mkdir -p /var/run/sampleapp

  # systemd configuration
  cat << EOF > /etc/systemd/system/sampleapp.service
  [Unit]
  Description=Sample Jar app
  After=syslog.target

  [Service]
  User=root
  ExecStart=/bin/java -jar /var/run/sampleapp/app.jar
  SuccessExitStatus=143

  [Install]
  WantedBy=multi-user.target
  EOF
  USERDATA
}
#
## EC2 - Standby 環境
## https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
## /var/run/sampleapp のディレクトリが存在しない
#module "ec2_standby" {
#  source  = "terraform-aws-modules/ec2-instance/aws"
#  version = "5.3.1"
#
#  ami                         = data.aws_ami.redhat_linux.image_id
#  associate_public_ip_address = true
#  availability_zone           = "ap-northeast-1a"
#  create_iam_instance_profile = true
#  iam_role_name               = local.name_tag
#  iam_role_policies = {
#    AmazonSSMManagedEC2InstanceDefaultPolicy = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
#    CodeDeployS3Policy                       = aws_iam_policy.codedeploy_s3.arn
#  }
#  instance_type = "t3.micro"
#  name          = local.name_tag
#  subnet_id     = module.vpc.public_subnets[0]
#  vpc_security_group_ids = [
#    aws_security_group.ec2.id,
#  ]
#  instance_tags = {
#    Name   = local.name_tag
#    Status = "Standby"
#  }
#  user_data = <<-USERDATA
#  #!/bin/bash
#  # setup ssm-agent
#  yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
#
#  # setup awscli
#  yum install -y python3
#  yum install -y python3-pip
#  pip3 install awscli
#
#  # user add
#  useradd batch-sample
#
#  # setup codedeploy-agent
#  yum install -y ruby
#  curl https://aws-codedeploy-ap-northeast-1.s3.ap-northeast-1.amazonaws.com/latest/install -O
#  # https://repost.aws/questions/QUgNz4VGCFSC2TYekM-6GiDQ/dnf-yum-both-fails-while-being-executed-on-instance-bootstrap-on-amazon-linux-2023
#  # RPM: error: can't create transaction lock on /var/lib/rpm/.rpm.lock (Resource temporarily unavailable)
#  sleep 30
#  chmod +x ./install
#  ./install auto
#  rm -f ./install
#
#  # setup java
#  yum install -y java
#
#  # systemd configuration
#  cat << EOF > /etc/systemd/system/sampleapp.service
#  [Unit]
#  Description=Sample Jar app
#  After=syslog.target
#
#  [Service]
#  User=root
#  ExecStart=/bin/java -jar /var/run/sampleapp/app.jar
#  SuccessExitStatus=143
#
#  [Install]
#  WantedBy=multi-user.target
#  EOF
#  USERDATA
#}
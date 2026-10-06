# ---------- 1. Custom Policy: Full access to EC2, S3, VPC ----------
data "aws_iam_policy_document" "full_infra_access" {
  statement {
    sid       = "EC2FullAccess"
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }

  statement {
    sid     = "S3FullAccess"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::*",
      "arn:aws:s3:::*/*"
    ]
  }

  statement {
    sid    = "VPCFullAccess"
    effect = "Allow"
    actions = [
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:DescribeVpcs",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:DescribeSubnets",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:CreateInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:DeleteNatGateway",
      "ec2:AllocateAddress",
      "ec2:ReleaseAddress",
      "ec2:CreateVpcEndpoint",
      "ec2:DeleteVpcEndpoint"
    ]
    resources = ["*"]
  }
}

# ---------- 2. Ubuntu 24.04 LTS x86_64 AMI for c7i-flex.large ----------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
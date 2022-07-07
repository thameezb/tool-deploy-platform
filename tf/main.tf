provider "aws" {
  region = var.region
  default_tags {
    tags = {
      application : "kubernetes"
      business-unit : "retail"
      tooling : "terraform"
      environment : var.environment
      owner : var.team_name
      project : var.project_name
      deployer : var.deployer_name
      region : var.region
    }
  }
}

terraform {
  backend "s3" {
  }
}

data "aws_vpc" "default" {
  tags = {
    Name : local.vpc_name
  }
}

data "aws_subnets" "compute_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  tags = { "tier" = "compute" }
}

data "aws_subnets" "storage_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  tags = { "tier" = "storage" }
}

data "aws_default_tags" "current" {}

// --------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "allow_all" {
  name        = "ag-ret-allow-all"
  description = "Enable full access to VPC"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

// --------------------------------------------------------------------------------------------------------------
// IAM Policy 
data "aws_iam_policy" "ag-allow_all" {
  name = "ag-ci-cd-service-role-policy"
}

// --------------------------------------------------------------------------------------------------------------
// AMI
data "aws_caller_identity" "current" {}

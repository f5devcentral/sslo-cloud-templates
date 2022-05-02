## Create the VPCs for both stacks

resource "aws_vpc" "securitystack" {
  cidr_block           = var.vpc_cidrs["vpc"]
  enable_dns_hostnames = "true"
  tags = {
    Name = "${var.prefix}-sslo-securitystack"
  }
}

resource "aws_vpc" "appstack" {
  cidr_block           = var.vpc_cidrs["application"]
  enable_dns_hostnames = "true"
  tags = {
    Name = "${var.prefix}-sslo-appstack"
  }
}

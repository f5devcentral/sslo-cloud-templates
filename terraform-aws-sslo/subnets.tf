## Create Management Subnet 
resource "aws_subnet" "management" {
  vpc_id            = aws_vpc.securitystack.id
  cidr_block        = var.vpc_cidrs["management"]
  availability_zone = var.az
  tags = {
    Name       = "${var.prefix}-subnet_management"
    Group_Name = "${var.prefix}-subnet_management"
  }
}


## Create External Subnet
resource "aws_subnet" "external" {
  vpc_id            = aws_vpc.securitystack.id
  cidr_block        = var.vpc_cidrs["external"]
  availability_zone = var.az
  tags = {
    Name       = "${var.prefix}-subnet_external"
    Group_Name = "${var.prefix}-subnet_external"
  }
}


## Create dmz1 Subnet
resource "aws_subnet" "dmz1" {
  vpc_id            = aws_vpc.securitystack.id
  cidr_block        = var.vpc_cidrs["dmz1"]
  availability_zone = var.az
  tags = {
    Name       = "${var.prefix}-subnet_dmz1"
    Group_Name = "${var.prefix}-subnet_dmz1"
  }
}


## Create dmz2 Subnet
resource "aws_subnet" "dmz2" {
  vpc_id            = aws_vpc.securitystack.id
  cidr_block        = var.vpc_cidrs["dmz2"]
  availability_zone = var.az
  tags = {
    Name       = "${var.prefix}-subnet_dmz2"
    Group_Name = "${var.prefix}-subnet_dmz2"
  }
}


## Create dmz3 Subnet
resource "aws_subnet" "dmz3" {
  vpc_id            = aws_vpc.securitystack.id
  cidr_block        = var.vpc_cidrs["dmz3"]
  availability_zone = var.az
  tags = {
    Name       = "${var.prefix}-subnet_dmz3"
    Group_Name = "${var.prefix}-subnet_dmz3"
  }
}


## Create dmz4 Subnet
resource "aws_subnet" "dmz4" {
  vpc_id            = aws_vpc.securitystack.id
  cidr_block        = var.vpc_cidrs["dmz4"]
  availability_zone = var.az
  tags = {
    Name       = "${var.prefix}-subnet_dmz4"
    Group_Name = "${var.prefix}-subnet_dmz4"
  }
}


## Create Internal Subnet
resource "aws_subnet" "internal" {
  vpc_id            = aws_vpc.securitystack.id
  cidr_block        = var.vpc_cidrs["internal"]
  availability_zone = var.az
  tags = {
    Name       = "${var.prefix}-subnet_internal"
    Group_Name = "${var.prefix}-subnet_internal"
  }
}


## Create Application Subnet
resource "aws_subnet" "application" {
  vpc_id            = aws_vpc.appstack.id
  cidr_block        = var.vpc_cidrs["application"]
  availability_zone = var.az
  tags = {
    Name       = "${var.prefix}-subnet_application"
    Group_Name = "${var.prefix}-subnet_application"
  }
}

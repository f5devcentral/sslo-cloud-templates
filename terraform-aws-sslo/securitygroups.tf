## Create Security Group for Management
resource "aws_security_group" "management" {
  vpc_id      = aws_vpc.securitystack.id
  description = "sg_management"
  name        = "sg_management"
  tags = {
    Name = "${var.prefix}-sg_management"
  }
  ingress {
    # SSH (change to whatever ports you need)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.mgmt_src_addr_prefixes
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


## Create Security Group for External
resource "aws_security_group" "external" {
  vpc_id      = aws_vpc.securitystack.id
  description = "sg_external"
  name        = "sg_external"
  tags = {
    Name = "${var.prefix}-sg_external"
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


## Create Security Group for Internal
resource "aws_security_group" "internal" {
  vpc_id      = aws_vpc.securitystack.id
  description = "sg_internal"
  name        = "sg_internal"
  tags = {
    Name = "${var.prefix}-sg_internal"
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


## Create Security Group for Inspection Zone
resource "aws_security_group" "inspection_zone" {
  vpc_id      = aws_vpc.securitystack.id
  description = "sg_inspection_zone"
  name        = "sg_inspection_zone"
  tags = {
    Name = "${var.prefix}-sg_inspection_zone"
  }
  ingress {
    # Allow All (change to whatever ports you need)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


## Create Security Group for TGW Webapp
resource "aws_security_group" "appstack" {
  vpc_id      = aws_vpc.appstack.id
  description = "sg_appstack"
  name        = "sg_appstack"
  tags = {
    Name = "${var.prefix}-sg_appstack"
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

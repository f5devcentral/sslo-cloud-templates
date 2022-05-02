## Create the IGW
resource "aws_internet_gateway" "sslo" {
  vpc_id = aws_vpc.securitystack.id
  tags = {
    Name = "${var.prefix}-igw_sslo"
  }
}


## Create the Route Table for 'management' and 'external' subnets
resource "aws_route_table" "internet" {
  vpc_id = aws_vpc.securitystack.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sslo.id
  }

  tags = {
    Name = "${var.prefix}-rt_internet"
  }
}


# Create the Main SSLO Security Stack Route Table association
#resource "aws_main_route_table_association" "main" {
#  vpc_id         = aws_vpc.securitystack.id
#  route_table_id = aws_route_table.internet.id
#}

## Create the Route Table Associations
resource "aws_route_table_association" "management" {
  subnet_id      = aws_subnet.management.id
  route_table_id = aws_route_table.internet.id
}

resource "aws_route_table_association" "external" {
  subnet_id      = aws_subnet.external.id
  route_table_id = aws_route_table.internet.id
}


## Create the Route Table for 'dmz1' subnet
resource "aws_route_table" "dmz1" {
  vpc_id = aws_vpc.securitystack.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.bigip_dmz1.id
  }
  route {
    cidr_block           = var.vpc_cidrs["external"]
    network_interface_id = aws_network_interface.inspection_device_1_dmz1.id
  }
  tags = {
    Name = "${var.prefix}-rt_inspection_device_1_dmz1"
  }
}

## Create the Route Table Association
resource "aws_route_table_association" "dmz1" {
  subnet_id      = aws_subnet.dmz1.id
  route_table_id = aws_route_table.dmz1.id
}


## Create the Route Table for 'dmz2' subnet
resource "aws_route_table" "dmz2" {
  vpc_id = aws_vpc.securitystack.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.inspection_device_1_dmz2.id
  }
  route {
    cidr_block           = var.vpc_cidrs["external"]
    network_interface_id = aws_network_interface.bigip_dmz2.id
  }
  tags = {
    Name = "${var.prefix}-rt_inspection_device_1_dmz2"
  }
}

## Create the Route Table Association
resource "aws_route_table_association" "dmz2" {
  subnet_id      = aws_subnet.dmz2.id
  route_table_id = aws_route_table.dmz2.id
}


## Create the Route Table for 'dmz3' subnet
resource "aws_route_table" "dmz3" {
  vpc_id = aws_vpc.securitystack.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.bigip_dmz3.id
  }
  route {
    cidr_block           = var.vpc_cidrs["external"]
    network_interface_id = aws_network_interface.inspection_device_2_dmz3.id
  }
  tags = {
    Name = "${var.prefix}-rt_inspection_device_2_dmz3"
  }
}

## Create the Route Table Association
resource "aws_route_table_association" "dmz3" {
  subnet_id      = aws_subnet.dmz3.id
  route_table_id = aws_route_table.dmz3.id
}


## Create the Route Table for 'dmz4' subnet
resource "aws_route_table" "dmz4" {
  vpc_id = aws_vpc.securitystack.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.inspection_device_2_dmz4.id
  }
  route {
    cidr_block           = var.vpc_cidrs["external"]
    network_interface_id = aws_network_interface.bigip_dmz4.id
  }
  tags = {
    Name = "${var.prefix}-rt_inspection_device_2_dmz4"
  }
}

## Create the Route Table Association
resource "aws_route_table_association" "dmz4" {
  subnet_id      = aws_subnet.dmz4.id
  route_table_id = aws_route_table.dmz4.id
}


## Create the Route Table for 'internal' subnet
resource "aws_route_table" "internal" {
  vpc_id = aws_vpc.securitystack.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.bigip_internal.id
  }
  route {
    cidr_block         = var.vpc_cidrs["application"]
    transit_gateway_id = aws_ec2_transit_gateway.sslo.id
  }
  tags = {
    Name = "${var.prefix}-rt_internal"
  }
}

## Create the Route Table Association
resource "aws_route_table_association" "internal" {
  subnet_id      = aws_subnet.internal.id
  route_table_id = aws_route_table.internal.id
}


## Create the Route Table for 'application' subnet
resource "aws_route_table" "application" {
  vpc_id = aws_vpc.appstack.id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.sslo.id
  }
  tags = {
    Name = "${var.prefix}-rt_application"
  }
}

# Create the Main Route Table Association
#resource "aws_main_route_table_association" "application" {
#  vpc_id         = aws_vpc.appstack.id
#  route_table_id = aws_route_table.application.id
#}

## Create the Route Table Association for 'application' subnet
resource "aws_route_table_association" "application" {
  subnet_id      = aws_subnet.application.id
  route_table_id = aws_route_table.application.id
}

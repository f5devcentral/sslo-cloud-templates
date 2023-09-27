#
# Deploy BIG-IP VM
#

## Create network interfaces

## Create Management Network Interface for BIG-IP
resource "aws_network_interface" "bigip_management" {
  private_ips       = ["${cidrhost(var.vpc_cidrs["management"], 11)}"]
  subnet_id         = aws_subnet.management.id
  source_dest_check = "false"
  security_groups   = [aws_security_group.management.id]
  tags = {
    Name = "${var.prefix}-eni_bigip_management"
  }
}

## Create External Network Interface for BIG-IP 
resource "aws_network_interface" "bigip_external" {
  private_ips       = ["${cidrhost(var.vpc_cidrs["external"], 11)}", "${var.app_vip}"]
  subnet_id         = aws_subnet.external.id
  source_dest_check = "false"
  security_groups   = [aws_security_group.external.id]
  tags = {
    Name = "${var.prefix}-eni_bigip_external"
  }
}

## Create Internal Network Interface for BIG-IP
resource "aws_network_interface" "bigip_internal" {
  private_ips       = ["${cidrhost(var.vpc_cidrs["internal"], 11)}"]
  subnet_id         = aws_subnet.internal.id
  source_dest_check = "false"
  security_groups   = [aws_security_group.internal.id]
  tags = {
    Name = "${var.prefix}-eni_bigip_internal"
  }
}

## Create dmz1 Network Interface for BIG-IP
resource "aws_network_interface" "bigip_dmz1" {
  private_ips       = ["${cidrhost(var.vpc_cidrs["dmz1"], 7)}", "${cidrhost(var.vpc_cidrs["dmz1"], 8)}"]
  subnet_id         = aws_subnet.dmz1.id
  source_dest_check = "false"
  security_groups   = [aws_security_group.inspection_zone.id]
  tags = {
    Name = "${var.prefix}-eni_bigip_dmz1"
  }
}

## Create dmz2 Network Interface for BIG-IP
resource "aws_network_interface" "bigip_dmz2" {
  private_ips       = ["${cidrhost(var.vpc_cidrs["dmz2"], 117)}", "${cidrhost(var.vpc_cidrs["dmz2"], 116)}"]
  subnet_id         = aws_subnet.dmz2.id
  source_dest_check = "false"
  security_groups   = [aws_security_group.inspection_zone.id]
  tags = {
    Name = "${var.prefix}-eni_bigip_dmz2"
  }
}

## Create dmz3 Network Interface for BIG-IP
resource "aws_network_interface" "bigip_dmz3" {
  private_ips       = ["${cidrhost(var.vpc_cidrs["dmz3"], 7)}", "${cidrhost(var.vpc_cidrs["dmz3"], 8)}"]
  subnet_id         = aws_subnet.dmz3.id
  source_dest_check = "false"
  security_groups   = [aws_security_group.inspection_zone.id]
  tags = {
    Name = "${var.prefix}-eni_bigip_dmz3"
  }
}

## Create dmz4 Network Interface for BIG-IP
resource "aws_network_interface" "bigip_dmz4" {
  private_ips       = ["${cidrhost(var.vpc_cidrs["dmz4"], 117)}", "${cidrhost(var.vpc_cidrs["dmz4"], 116)}"]
  subnet_id         = aws_subnet.dmz4.id
  source_dest_check = "false"
  security_groups   = [aws_security_group.inspection_zone.id]
  tags = {
    Name = "${var.prefix}-eni_bigip_dmz4"
  }
}


## Create Public IPs and associate to network interfaces
resource "aws_eip" "bigip_management" {
  vpc               = true
  public_ipv4_pool  = "amazon"
  network_interface = aws_network_interface.bigip_management.id
  tags = {
    Name = "${var.prefix}-eip_bigip_management"
  }
}

resource "aws_eip" "sslo_vip" {
  vpc                       = true
  public_ipv4_pool          = "amazon"
  network_interface         = aws_network_interface.bigip_external.id
  associate_with_private_ip = var.app_vip
  tags = {
    Name = "${var.prefix}-eip_bigip_vip"
  }
}


#
# BIG-IP
#
locals {
  onboard_template = templatefile("${path.module}/f5_onboard.tmpl", {
    license_key     = var.license_key
    admin_password  = var.admin_password
    internal_selfip = "${cidrhost(var.vpc_cidrs["internal"], 11)}/24"
    external_selfip = "${cidrhost(var.vpc_cidrs["external"], 11)}/24"
    app_route_dest  = var.vpc_cidrs["application"]
    app_route_gw    = "${cidrhost(var.vpc_cidrs["internal"], 1)}"
    sslo_pkg_name   = var.sslo_pkg_name
  })
}

## Create BIG-IP
resource "aws_instance" "sslo" {
  depends_on        = [aws_eip.bigip_management, aws_route_table_association.management]
  ami               = var.sslo_ami
  instance_type     = var.instance_type
  key_name          = aws_key_pair.my_keypair.key_name
  availability_zone = var.az
  user_data         = local.onboard_template

  tags = {
    Name = "${var.prefix}-vm_bigip_sslo"
  }
  # set the mgmt interface 
  network_interface {
    network_interface_id = aws_network_interface.bigip_management.id
    device_index         = 0
  }
  # set the external interface 
  network_interface {
    network_interface_id = aws_network_interface.bigip_external.id
    device_index         = 1
  }
  # set the internal interface 
  network_interface {
    network_interface_id = aws_network_interface.bigip_internal.id
    device_index         = 2
  }
  # set the inspection zone (dmz1) interface 
  network_interface {
    network_interface_id = aws_network_interface.bigip_dmz1.id
    device_index         = 3
  }
  # set the inspection zone (dmz2) interface 
  network_interface {
    network_interface_id = aws_network_interface.bigip_dmz2.id
    device_index         = 4
  }
  # set the inspection zone (dmz3) interface 
  network_interface {
    network_interface_id = aws_network_interface.bigip_dmz3.id
    device_index         = 5
  }
  # set the inspection zone (dmz4) interface 
  network_interface {
    network_interface_id = aws_network_interface.bigip_dmz4.id
    device_index         = 6
  }
}

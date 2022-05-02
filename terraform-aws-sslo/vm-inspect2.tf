#
# Create Inspection Device 2
#

## Create Management Network Interface for Inspection Device 2
resource "aws_network_interface" "inspection_device_2_mgmt" {
  subnet_id         = aws_subnet.management.id
  source_dest_check = "false"
  security_groups   = [aws_security_group.management.id]
  tags = {
    Name = "${var.prefix}-eni_inspection_device_2_mgmt"
  }
}

## Create dmz3 Network Interface for Inspection Device 2
resource "aws_network_interface" "inspection_device_2_dmz3" {
  private_ips       = ["${cidrhost(var.vpc_cidrs["dmz3"], 21)}"]
  subnet_id         = aws_subnet.dmz3.id
  source_dest_check = "false"
  security_groups   = [aws_security_group.inspection_zone.id]
  tags = {
    Name = "${var.prefix}-eni_inspection_device_2_dmz3"
  }
}

## Create dmz4 Network Interface for Inspection Device 2
resource "aws_network_interface" "inspection_device_2_dmz4" {
  private_ips       = ["${cidrhost(var.vpc_cidrs["dmz4"], 21)}"]
  subnet_id         = aws_subnet.dmz4.id
  source_dest_check = "false"
  security_groups   = [aws_security_group.inspection_zone.id]
  tags = {
    Name = "${var.prefix}-eni_inspection_device_2_dmz4"
  }
}


## Inspection Device 2 
resource "aws_instance" "inspection_device_2" {
  #depends_on        = [aws_internet_gateway.sslo]
  ami               = var.inspection_ami
  instance_type     = "t2.small"
  key_name          = aws_key_pair.my_keypair.key_name
  availability_zone = var.az
  user_data         = <<-EOF
                      #!/usr/bin/bash
                      ip route delete default
                      ip route add default via ${cidrhost(var.vpc_cidrs["dmz3"], 1)} metric 1
                      ip route add ${var.vpc_cidrs["external"]} via ${cidrhost(var.vpc_cidrs["dmz4"], 1)}
                      sysctl -w net.ipv4.ip_forward=1
                      EOF

  tags = {
    Name = "${var.prefix}-vm_inspection_device_2"
  }
  network_interface {
    network_interface_id = aws_network_interface.inspection_device_2_mgmt.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.inspection_device_2_dmz3.id
    device_index         = 1
  }
  network_interface {
    network_interface_id = aws_network_interface.inspection_device_2_dmz4.id
    device_index         = 2
  }
}

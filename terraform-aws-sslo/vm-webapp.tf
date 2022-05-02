## Create the Network Interface for the WebServer
resource "aws_network_interface" "webapp" {
  private_ips       = ["${cidrhost(var.vpc_cidrs["application"], 200)}"]
  subnet_id         = aws_subnet.application.id
  source_dest_check = "false"
  security_groups   = [aws_security_group.appstack.id]
  tags = {
    Name = "${var.prefix}-eni_webapp"
  }
}

## Create Test WebApp Server

resource "aws_instance" "webapp-server" {
  #depends_on        = [aws_internet_gateway.sslo]
  ami               = var.webapp_ami
  instance_type     = "t3.small"
  key_name          = aws_key_pair.my_keypair.key_name
  availability_zone = var.az
  tags = {
    Name = "${var.prefix}-vm_webapp"
  }
  network_interface {
    network_interface_id = aws_network_interface.webapp.id
    device_index         = 0
  }
}

resource "tls_private_key" "my_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my_keypair" {
  key_name   = var.ec2_key_name
  public_key = tls_private_key.my_keypair.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.my_keypair.private_key_pem
  filename        = "${var.ec2_key_name}.key"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = tls_private_key.my_keypair.public_key_openssh
  filename        = "${var.ec2_key_name}.pub"
  file_permission = "0600"
}

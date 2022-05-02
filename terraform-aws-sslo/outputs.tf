output "sslo_internal" {
  value       = aws_network_interface.bigip_internal.private_ip
  description = "The private IP address of SSLO internal interface."
}

output "sslo_external" {
  value       = aws_network_interface.bigip_external.private_ips
  description = "The private IP address of SSLO external interface."
}

output "sslo_dmz1" {
  value       = aws_network_interface.bigip_dmz1.private_ips
  description = "The private IP address of SSLO dmz1 interface."
}

output "sslo_dmz2" {
  value       = aws_network_interface.bigip_dmz2.private_ips
  description = "The private IP address of SSLO dmz2 interface."
}

output "sslo_dmz3" {
  value       = aws_network_interface.bigip_dmz3.private_ips
  description = "The private IP address of SSLO dmz3 interface."
}

output "sslo_dmz4" {
  value       = aws_network_interface.bigip_dmz4.private_ips
  description = "The private IP address of SSLO dmz4 interface."
}

output "sslo_management" {
  value       = aws_network_interface.bigip_management.private_ip
  description = "The private IP address of SSLO management interface."
}

output "sslo_management_public_ip" {
  value       = aws_instance.sslo.public_ip
  description = "The public IP address of SSLO management interface."
}

output "sslo_management_public_dns" {
  value       = aws_instance.sslo.public_dns
  description = "The public DNS of SSLO."
}

output "sslo_vip" {
  value       = aws_eip.sslo_vip.public_ip
  description = "The public IP of the VIP"
}

output "webapp_internal" {
  value       = aws_instance.webapp-server.private_ip
  description = "Private IP of the web app server"
}

output "inspection_service_ip_1" {
  value       = aws_network_interface.inspection_device_1_dmz1.private_ip
  description = "Private IP of the Inspection Service One IP"
}

output "inspection_service_ip_2" {
  value       = aws_network_interface.inspection_device_2_dmz3.private_ip
  description = "Private IP of the Inspection Service Two IP"
}

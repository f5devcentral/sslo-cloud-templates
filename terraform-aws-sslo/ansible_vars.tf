resource "local_file" "ansible_vars" {
  content  = <<-DOC
     ansible_host: ${aws_instance.sslo.public_ip}
     ansible_httpapi_password: "${var.admin_password}"
     snort1_host: ${aws_network_interface.inspection_device_1_dmz1.private_ip}
     snort2_host: ${aws_network_interface.inspection_device_2_dmz3.private_ip}
     webapp_pool: ${aws_instance.webapp-server.private_ip}
     sslo_vip: ${aws_eip.sslo_vip.private_ip}
     
     DOC
  filename = "./ansible_vars.yaml"
}

# Outputs for Terraform configuration

output "master_public_ip" {
  description = "Public IP of master node"
  value       = aws_instance.master.public_ip
}

output "master_private_ip" {
  description = "Private IP of master node"
  value       = aws_instance.master.private_ip
}

output "slave_public_ips" {
  description = "Public IPs of slave nodes"
  value       = aws_instance.slave[*].public_ip
}

output "slave_private_ips" {
  description = "Private IPs of slave nodes"
  value       = aws_instance.slave[*].private_ip
}

output "nagios_url" {
  description = "Nagios web interface URL"
  value       = "http://${aws_instance.master.public_ip}/nagios"
}

output "puppet_master_connection" {
  description = "SSH command to connect to Puppet Master"
  value       = "ssh -i ${var.create_new_key ? "private-key.pem" : "<your-key>.pem"} ubuntu@${aws_instance.master.public_ip}"
}

output "slave_connections" {
  description = "SSH commands to connect to slave nodes"
  value = [
    for idx, instance in aws_instance.slave :
    "ssh -i ${var.create_new_key ? "private-key.pem" : "<your-key>.pem"} ubuntu@${instance.public_ip}"
  ]
}

output "private_key_path" {
  description = "Path to generated private key (if created)"
  value       = var.create_new_key ? "${path.module}/private-key.pem" : "Use your existing key"
}

output "ssh_key_name" {
  description = "Name of SSH key pair being used"
  value       = local.key_name
}

output "nagios_slaves_config_path" {
  description = "Path to generated Nagios slaves configuration"
  value       = local_file.nagios_slaves_config.filename
}

output "deployment_instructions" {
  description = "Instructions to complete the deployment"
  value       = <<-EOT
    DEPLOYMENT COMPLETE! Follow these steps:
    
    1. Wait 5-10 minutes for services to initialize
    
    2. Upload Nagios slaves configuration:
       scp -i ${var.create_new_key ? "private-key.pem" : "<your-key>.pem"} generated/slaves.cfg ubuntu@${aws_instance.master.public_ip}:/tmp/
    
    3. SSH to master and apply configuration:
       ssh -i ${var.create_new_key ? "private-key.pem" : "<your-key>.pem"} ubuntu@${aws_instance.master.public_ip}
       sudo mv /tmp/slaves.cfg /usr/local/nagios/etc/objects/slaves.cfg
       sudo systemctl restart nagios
    
    4. Access Nagios: http://${aws_instance.master.public_ip}/nagios
       Username: nagiosadmin
       Password: nagiosadmin (CHANGE THIS!)
  EOT
}


# SSH Key Pair Management
# This file creates an AWS key pair from a public key

# Generate a new key pair locally (optional)
resource "tls_private_key" "ssh_key" {
  count     = var.create_new_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS Key Pair from generated public key
resource "aws_key_pair" "generated" {
  count      = var.create_new_key ? 1 : 0
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ssh_key[0].public_key_openssh

  tags = {
    Name = "${var.project_name}-key"
  }
}

# Save private key to local file (SECURE THIS FILE!)
resource "local_file" "private_key" {
  count           = var.create_new_key ? 1 : 0
  content         = tls_private_key.ssh_key[0].private_key_pem
  filename        = "${path.module}/private-key.pem"
  file_permission = "0600"
}

# Use either the generated key or existing key
locals {
  key_name = var.create_new_key ? aws_key_pair.generated[0].key_name : var.key_name
}

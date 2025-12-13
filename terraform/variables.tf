# Variables for Terraform configuration

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "master-slave-infra"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "master_instance_type" {
  description = "EC2 instance type for master node"
  type        = string
  default     = "t3.medium"
}

variable "slave_instance_type" {
  description = "EC2 instance type for slave nodes"
  type        = string
  default     = "t3.small"
}

variable "slave_count" {
  description = "Number of slave nodes"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "Name of the SSH key pair (only used if create_new_key is false)"
  type        = string
  default     = ""
}

variable "create_new_key" {
  description = "Create a new SSH key pair (true) or use existing (false)"
  type        = bool
  default     = true
}

variable "existing_key_path" {
  description = "Path to existing private key file (only used if create_new_key is false)"
  type        = string
  default     = ""
}

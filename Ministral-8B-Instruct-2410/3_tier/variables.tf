variable "region" {
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for EC2 instances"
  default     = "ami-052064a798f08f0d3"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type to use"
  default     = "t2.micro"
  type        = string
}

variable "key_pair_name" {
  description = "The name of the key pair to use for EC2 instances"
  default     = "3-tier-key-pair"
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for RDS instance"
  default     = false
  type        = bool
}

variable "db_username" {
  description = "The RDS MySQL username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The RDS MySQL password"
  type        = string
  sensitive   = true
}

variable "cidr_block_vpc" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
  type        = string
}

variable "cidr_block_public" {
  description = "The CIDR block for the public subnets"
  default     = "10.0.1.0/24"
  type        = string
}

variable "cidr_block_private_app" {
  description = "The CIDR block for the app tier private subnets"
  default     = "10.0.3.0/24"
  type        = string
}

variable "cidr_block_private_db" {
  description = "The CIDR block for the database tier private subnets"
  default     = "10.0.5.0/24"
  type        = string
}



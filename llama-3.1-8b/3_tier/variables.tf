variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "public_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "CIDR blocks for public subnets"
}

variable "private_app_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
  description = "CIDR blocks for private app subnets"
}

variable "private_database_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
  description = "CIDR blocks for private database subnets"
}

variable "ami_id" {
  type        = string
  default     = "ami-052064a798f08f0d3"
  description = "AMI ID for EC2 instances"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type for EC2 instances"
}

variable "key_pair_name" {
  type        = string
  default     = "3-tier-key-pair"
  description = "Key pair name for EC2 instances"
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Multi-AZ deployment for RDS instance"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Instance class for RDS instance"
}

variable "db_allocated_storage" {
  type        = number
  default     = 10
  description = "Allocated storage for RDS instance"
}

variable "db_username" {
  type        = string
  sensitive   = true
  description = "Username for RDS instance"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Password for RDS instance"
}

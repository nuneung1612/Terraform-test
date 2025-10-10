# -----------------------------------------------------------------------------
# General Configuration
# -----------------------------------------------------------------------------
variable "project_name" {
  description = "The name of the project, used for tagging resources."
  type        = string
  default     = "3-tier-webapp"
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "The CIDR block for the first public subnet (us-east-1a)."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "The CIDR block for the second public subnet (us-east-1b)."
  type        = string
  default     = "10.0.2.0/24"
}

variable "app_subnet_1_cidr" {
  description = "The CIDR block for the first private app subnet (us-east-1a)."
  type        = string
  default     = "10.0.3.0/24"
}

variable "app_subnet_2_cidr" {
  description = "The CIDR block for the second private app subnet (us-east-1b)."
  type        = string
  default     = "10.0.4.0/24"
}

variable "db_subnet_1_cidr" {
  description = "The CIDR block for the first private database subnet (us-east-1a)."
  type        = string
  default     = "10.0.5.0/24"
}

variable "db_subnet_2_cidr" {
  description = "The CIDR block for the second private database subnet (us-east-1b)."
  type        = string
  default     = "10.0.6.0/24"
}

# -----------------------------------------------------------------------------
# Compute Configuration
# -----------------------------------------------------------------------------
variable "ami_id" {
  description = "The AMI ID for the EC2 instances."
  type        = string
  default     = "ami-052064a798f08f0d3" # Amazon Linux 2023 - us-east-1
}

variable "web_instance_type" {
  description = "The instance type for the web tier EC2 instances."
  type        = string
  default     = "t2.micro"
}

variable "app_instance_type" {
  description = "The instance type for the app tier EC2 instances."
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "The name of the key pair to use for EC2 instances."
  type        = string
  default     = "3-tier-key-pair"
}

# -----------------------------------------------------------------------------
# Database Configuration
# -----------------------------------------------------------------------------
variable "db_instance_class" {
  description = "The instance class for the RDS database."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database to create in the RDS instance."
  type        = string
  default     = "sqldb"
}

variable "db_username" {
  description = "The username for the RDS database administrator."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the RDS database administrator."
  type        = string
  sensitive   = true
}

variable "db_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ."
  type        = bool
  default     = false
}

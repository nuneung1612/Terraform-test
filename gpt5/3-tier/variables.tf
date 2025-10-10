// variables.tf
variable "vpc_cidr"          { type = string default = "10.0.0.0/16" }
variable "public_subnet_cidrs" { type = list(string) default = ["10.0.1.0/24","10.0.2.0/24"] }
variable "app_subnet_cidrs"    { type = list(string) default = ["10.0.3.0/24","10.0.4.0/24"] }
variable "db_subnet_cidrs"     { type = list(string) default = ["10.0.5.0/24","10.0.6.0/24"] }

variable "ami_id"           { type = string default = "ami-052064a798f08f0d3" }
variable "web_instance_type"{ type = string default = "t2.micro" }
variable "app_instance_type"{ type = string default = "t2.micro" }
variable "key_name"         { type = string default = "3-tier-key-pair" }

variable "rds_instance_class" { type = string default = "db.t3.micro" }
variable "rds_engine_version" { type = string default = "8.0.39" }
variable "rds_db_name"        { type = string default = "sqldb" }
variable "rds_username"       { type = string sensitive = true }
variable "rds_password"       { type = string sensitive = true }
variable "rds_multi_az"       { type = bool   default  = false }

variable "tags" {
  type        = map(string)
  default     = { Project = "3-tier", Environment = "dev" }
  description = "Common tags"
}

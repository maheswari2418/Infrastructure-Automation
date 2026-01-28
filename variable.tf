variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "web_subnet_1_cidr" {
  description = "CIDR block for Web Tier Subnet 1 (ap-south-1a)"
  default     = "10.0.1.0/24"
}

variable "web_subnet_2_cidr" {
  description = "CIDR block for Web Tier Subnet 2 (ap-south-1b)"
  default     = "10.0.2.0/24"
}

variable "app_subnet_1_cidr" {
  description = "CIDR block for App Tier Subnet 1 (ap-south-1a)"
  default     = "10.0.10.0/24"
}

variable "app_subnet_2_cidr" {
  description = "CIDR block for App Tier Subnet 2 (ap-south-1b)"
  default     = "10.0.11.0/24"
}

variable "db_subnet_1_cidr" {
  description = "CIDR block for DB Tier Subnet 1 (ap-south-1a)"
  default     = "10.0.20.0/24"
}

variable "db_subnet_2_cidr" {
  description = "CIDR block for DB Tier Subnet 2 (ap-south-1b)"
  default     = "10.0.21.0/24"
}

variable "environment" {
  description = "Environment name"
  default     = "prod"
}

variable "db_engine" {
  description = "Database engine"
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  default     = "8.0"
}

variable "db_instance_class" {
  description = "Database instance class"
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  default     = "appdb"
}

variable "db_username" {
  description = "Database master username"
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  sensitive   = true
}

variable "app_instance_type" {
  description = "Instance type for app servers"
  default     = "t3.micro"
}

variable "web_instance_type" {
  description = "Instance type for web servers"
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for instances"
  default     = "ami-0b982602dbb32c5bd"
}
 
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "office_ip_cidr_blocks" {
  type    = list(string)
  default = []
}


variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT Gateway across AZs"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "allocated_storage" {
  description = "Allocated storage size (in GB)"
  type        = number
}

variable "storage_type" {
  description = "Storage type (e.g. gp2, gp3)"
  type        = string
}

variable "engine" {
  description = "Database engine (e.g. mysql, postgres)"
  type        = string
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "instance_class" {
  description = "Instance class (e.g. db.t3.medium)"
  type        = string
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot on destroy"
  type        = bool
}

variable "auto_minor_version_upgrade" {
  description = "Whether to enable auto minor version upgrades"
  type        = bool
}

variable "publicly_accessible" {
  description = "Whether the DB is publicly accessible"
  type        = bool
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
}

variable "multi_az" {
  description = "Whether to deploy Multi-AZ"
  type        = bool
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM authentication"
  type        = bool
}

variable "storage_encrypted" {
  description = "Whether to encrypt storage"
  type        = bool
}

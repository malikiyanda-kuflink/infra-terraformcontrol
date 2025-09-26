# variables.tf (environment repo)
variable "module_versions" {
  type = object({
    vpc = string
    iam = string
    rds = string
    # add others
  })
  default = {
    vpc = "0.2.1-rc1"
    iam = "0.1.0"
    rds = "0.3.2"
  }
}

# -----------------------------
# Variables (override in tfvars)
# -----------------------------
variable "onprem_public_ip" {
  description = "Static public IP of the on-prem firewall/router"
  default = "89.197.135.242"
  type        = string
}

variable "onprem_cidrs" {
  description = "List of on-premise CIDRs to route into AWS"
  type        = list(string)
  # If you want a default, it must be a LIST:
  default     = ["10.0.0.0/16"]
}

variable "private_route_table_ids" {
  type    = list(string)
  default = []
}

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


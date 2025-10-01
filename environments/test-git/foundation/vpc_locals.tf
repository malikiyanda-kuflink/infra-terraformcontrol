locals {
  vpc = {
    name = "Kuflink-Test-VPC"
    cidr = "172.40.0.0/16"
    azs  = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]

    public_cidrs  = ["172.40.1.0/24", "172.40.2.0/24", "172.40.3.0/24"]
    private_cidrs = ["172.40.11.0/24", "172.40.12.0/24", "172.40.13.0/24"]

    enable_nat = true
    single_nat = true
  }
}

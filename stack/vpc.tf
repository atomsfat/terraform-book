module "vpc" {
  source = "github.com/terraform-community-modules/tf_aws_vpc"

  name = "my-vpc"

  cidr = "${var.vpc_cidr}"

  /* enable_dns_hostnames = true */
  enable_dns_support = true

  private_subnets = ["${var.private_subnet_cidr}"]
  public_subnets = ["${var.public_subnet_cidr}"]

  enable_nat_gateway = "false"

  azs = ["us-east-1a"]

  tags {
    Name = "test"
    "Environment" = "${var.environment}"
  }
}

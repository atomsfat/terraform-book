module "vpc" {
  source = "github.com/terraform-community-modules/tf_aws_vpc"

  name = "my-vpc"

  cidr = "${var.vpc_cidr}"

  private_subnets = ["${var.private_subnet_cidr}"]
  public_subnets = ["${var.public_subnet_cidr}"]

  enable_nat_gateway = "true"

  azs = ["us-east-1a"]

  tags {
    Name = "test"
    "Environment" = "${var.environment}"
  }
}

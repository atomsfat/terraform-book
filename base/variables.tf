variable "access_key" {}
varibale "secret_key" {}

variable "region" {
  description = "The AWS region"
  default = "us-east-1"
}

variable "amis" {
  default = {
    "us-east-1" = "ami-0d729a60"
  }
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.1.0/24"
}

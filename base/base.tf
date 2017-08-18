provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_instance" "base" {
  ami = "ami-0d729a60"
  instance_type = "t2.micro"
}

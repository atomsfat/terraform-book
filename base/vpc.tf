resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "terraform-aws-vpc"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_security_group" "nat" {
  name = "vpc_nat"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr}"]
  }
  ingress {
    from_port = 443
    to_port = 443 
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr}"]
  }
  ingress {
    from_port = 22
    to_port =  22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port =  -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "NATSG"
  }
}

resource "aws_subnet" "us-east-1-public" {
  vpc_id = "${aws_vpc.default.id}"
  
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-east-1a"

  tags {
    Name = "Public subnet"
  }
}
  

resource "aws_instance" "nat" {
  ami = "ami-293a183f" # AMI for nat
  availability_zone = "us-east-1a"
  instance_type = "t2.nano"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.nat.id}"]
  subnet_id = "${aws_subnet.us-east-1-public.id}"
  associate_public_ip_address = true  
  source_dest_check = false

  tags {
    Name = "VPC NAT"
  }
}

resource "aws_eip" "nat" {
  instance = "${aws_instance.nat.id}"
  vpc = true
}


  
#public subnet

resource "aws_route_table" "us-east-1-public" {
  vpc_id = "${aws_vpc.default.id}"
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table_association" "us-east-1-public"{
  subnet_id = "${aws_subnet.us-east-1-public.id}"
  route_table_id = "${aws_route_table.us-east-1-public.id}"
}

#private subnet

resource "aws_subnet" "us-east-1-private" {
  vpc_id = "${aws_vpc.default.id}"
  
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-east-1a"

  tags {
    Name = "Private subnet"
  }
}

resource "aws_route_table" "us-east-1-private" {

  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block ="0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }
  
  tags {
    Name = "Private subnet"
  }
}

resource "aws_route_table_association" "us-east-1-private" {
  
  subnet_id = "${aws_subnet.us-east-1-private.id}"
  route_table_id = "${aws_route_table.us-east-1-private.id}"
 
}

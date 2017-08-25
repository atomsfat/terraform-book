resource "aws_security_group" "web"{
  name = "vpc_web"
  description = "Allows HTTP trafic"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  egress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr}"]
  }
  #trafic to the world
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${module.vpc.vpc_id}"

  tags {
    Name = "WebServerSG"
  }


}

resource "aws_instance" "web" {
  ami = "${lookup(var.amis, var.aws_region)}"
  availability_zone = "us-east-1a"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]
  subnet_id = "${element(module.vpc.public_subnets, 0)}"
  associate_public_ip_address = true
  source_dest_check = false

  private_ip = "${var.intance_ips[count.index]}"

  tags{
    Name = "Web server ${count.index}"
  }
  count = "${length(var.intance_ips)}"
}

resource "aws_security_group" "web_inbound_sg" {
  name = "web_inbound"
  description = "Allow HTTP trafic to ELB"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
/* allow all */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name = "web-elb"

  subnets = ["${module.vpc.public_subnets}"]
  security_groups = ["${aws_security_group.web_inbound_sg.id}"]


  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  instances = ["${aws_instance.web.*.id}"]

}

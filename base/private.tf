resource "aws_security_group" "db"{
  name = "vpc_db"
  description = "Allow incoming DB private trafic"

  ingress {
    from_port = 22
    to_port = 22 
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.web.id}"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "DBServerSG"
  }

}
resource "aws_instance" "db-1" {
  ami = "${lookup(var.amis, var.aws_region)}"
  availability_zone = "us-east-1a"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  subnet_id = "${aws_subnet.us-east-1-private.id}"
  associate_public_ip_address = true
  source_dest_check = false

  tags{
    Name = "DB server 1"
  }
}


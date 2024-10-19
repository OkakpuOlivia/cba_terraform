provider "aws" {
  region = var.region
}
data "aws_ssm_parameter" "instance_ami"{
  name ="/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_security_group" "cba_tf_sg" {
 name        = "cba_tf_sg"
 vpc_id = aws_vpc.cba_vpc.id
 description = "allow all traffic"
 ingress {
   from_port  = 22
   to_port    = 22
   protocol   = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
 ingress {
   from_port  = 80
   to_port    = 80
   protocol   = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
 egress {
   from_port  = 0
   to_port    = 0
   protocol   = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
 tags = {
   name = "CBAterraformSG"
 }
}

resource "aws_instance" "cba_tf_instance" {
  instance_type = var.instance_type
  subnet_id = aws_subnet.cba_public.id
  security_groups = [aws_security_group.cba_tf_sg.id]
  ami = data.aws_ssm_parameter.instance_ami.value
  key_name = var.key_name
  user_data = file("install_appache.sh")
  tags = {
    Name = "AppacheInstance"
    }
}

resource "aws_vpc" "cba_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = "true"
  instance_tenancy = "default"

  tags = {
    Name = "ApacheVPC"
  }
}

resource "aws_subnet" "cba_public" {
  vpc_id = aws_vpc.cba_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "ApachePublicSubnet"
  }
  
}

resource "aws_subnet" "cba_private" {
  vpc_id = aws_vpc.cba_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "ApachePrivateSubnet"
  }
  
}

resource "aws_internet_gateway" "cba_igw" {
  vpc_id = aws_vpc.cba_vpc.id
  
  tags = {
    Name = "AppacheIGW"
  }
}

resource "aws_route_table" "cba_public_rt" {
  vpc_id = aws_vpc.cba_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cba_igw.id
  }
  
  tags = {
    Name = "AppachePublicRT"
  }
}

resource "aws_route_table_association" "cba_subnet-rt_public"{
  subnet_id = aws_subnet.cba_public.id
  route_table_id = aws_route_table.cba_public_rt.id
}

data "aws_region" "current" {}

data "aws_key_pair" "sample_kp" {
  key_name = var.key_name
}

variable "region" {
  default = "eu-west-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "instance_ami" { 
  default = "ami-03c6b308140d10488"
}


variable "vpc_id" {
  default = ""
}


variable "key_name" {
  default = "JENKINS1"
}
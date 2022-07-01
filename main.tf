provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAUEU726P5QHVOSIZ4"
  secret_key = "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"
}

#vpc


#resource "aws_vpc" "vpc" {
#  cidr_block       = "10.0.0.0/16"
#  instance_tenancy = "default"

#}

#availability zones and subnets

variable "zones" {
  description = "for multi zone deployment"
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

data "aws_availability_zones" "zones" {}
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
#  tags {
#    Name = "vpc"
#  }
}
resource "aws_subnet" "my-public-subnet" {
  count                   = length(data.aws_availability_zones.zones.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.zones.names[0]
  map_public_ip_on_launch = true
}
resource "aws_subnet" "private_subnet1" {
  count                   = length(data.aws_availability_zones.zones.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.zones.names[0]
  map_public_ip_on_launch = false
}
resource "aws_subnet" "private_subnet2" {
  count                   = length(data.aws_availability_zones.zones.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.zones.names[0]
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public-route-table" {
vpc_id       = aws_vpc.vpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.gw.id
}
}
resource "aws_route_table_association" "public-subnet-1-route-table-association" {
subnet_id           = aws_subnet.my-public-subnet[0].id
route_table_id      = aws_route_table.public-route-table.id
}



#ec2 for database

resource "aws_instance" "db_instance" {
  ami           = "ami-006d3995d3a6b963b"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.private_subnet2[0].id

}







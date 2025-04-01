// Build the base VPC
resource "aws_vpc" "vpc" {
  #cidr_block = "${var.cidr_block}"
  cidr_block           = "10.${var.octet}.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name             = var.vpc_name
    Alpha_tech_Build = "true"
  }
}

// Build an internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw-${var.vpc_name}"
  }
}

// Build a NAT gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

// Build EIP for NAT gateway
resource "aws_eip" "nat" {
  vpc = true
}


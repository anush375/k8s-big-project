// Build route table for public subnets
resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public Subnets"
  }
}

// Build route table for private subnets
resource "aws_route_table" "private_subnets" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = "Private Subnets"
  }
}


/* ---------- Build private subnets ---------- */

// Build private subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.${var.octet}.11.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.vpc_name}_private_1"
    Type = "private"
  }
}

resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_subnets.id
}

// Build private subnet 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.${var.octet}.12.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name = "${var.vpc_name}_private_2"
    Type = "private"
  }
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_subnets.id
}

// Build private subnet 3
resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.${var.octet}.13.0/24"
  availability_zone = "${var.region}c"
  tags = {
    Name = "${var.vpc_name}_private_3"
    Type = "private"
  }
}

resource "aws_route_table_association" "private_subnet_3" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_subnets.id
}


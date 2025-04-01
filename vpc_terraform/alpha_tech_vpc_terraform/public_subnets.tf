/* ---------- Build public subnets ---------- */

// Build public subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.${var.octet}.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name             = "${var.vpc_name}_public_1"
    Type             = "public"
    Alpha_tech_Build = "true"
  }
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_subnets.id
}

// Build public subnet 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.${var.octet}.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    Name             = "${var.vpc_name}_public_2"
    Type             = "public"
    Alpha_tech_Build = "true"
  }
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_subnets.id
}

// Build public subnet 3
resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.${var.octet}.3.0/24"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true
  tags = {
    Name             = "${var.vpc_name}_public_3"
    Type             = "public"
    Alpha_tech_Build = "true"
  }
}

resource "aws_route_table_association" "public_subnet_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_subnets.id
}

// Build public subnet 4 - Management
resource "aws_subnet" "public_subnet_4" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.${var.octet}.99.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}_public_4"
    Type = "public"
  }
}

resource "aws_route_table_association" "public_subnet_4" {
  subnet_id      = aws_subnet.public_subnet_4.id
  route_table_id = aws_route_table.public_subnets.id
}


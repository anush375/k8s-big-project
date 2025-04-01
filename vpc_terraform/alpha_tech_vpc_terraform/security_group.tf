// Have terraform take over default SG
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Management security group
resource "aws_security_group" "mgmt" {
  name        = "${var.vpc_name}_management"
  description = "Allow all traffic from the management subnet"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      aws_subnet.public_subnet_4.cidr_block,
    ]
  }
}


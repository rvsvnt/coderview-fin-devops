resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "vpc-${var.region}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, 1)
  tags = {
    Name = "public-subnet-${var.region}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, 2)
  tags = {
    Name = "private-subnet-${var.region}"
  }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}
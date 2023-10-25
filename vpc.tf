resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = {
    Name = "Prometheus VPC"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "pub_subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "${var.aws_region}b"
}

resource "aws_subnet" "pub_subnet-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}c"
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "route_table_association-1" {
  subnet_id      = aws_subnet.pub_subnet-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "route_table_association-2" {
  subnet_id      = aws_subnet.pub_subnet-2.id
  route_table_id = aws_route_table.public.id
}

# private

resource "aws_subnet" "priv-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "${var.aws_region}b"
}

resource "aws_subnet" "priv-subnet-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "${var.aws_region}c"
}

resource "aws_eip" "nat_eip" {
  vpc        = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub_subnet-1.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "priv-subnet-1" {
  subnet_id      = aws_subnet.priv-subnet-1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "priv-subnet-2" {
  subnet_id      = aws_subnet.priv-subnet-2.id
  route_table_id = aws_route_table.private.id
}

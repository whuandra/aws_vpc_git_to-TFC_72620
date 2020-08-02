provider "aws" {
      region     = "${var.region}"
}

resource "aws_vpc" "default" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name      = "Vpc-Winoto3"
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidr_blocks)
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "private" {
    count = length(var.private_subnet_cidr_blocks)
    route_table_is = aws_route_table.private[count.index].id
    destination_cidr_block = "0.0.0.0/0"
   # nat_gateway_id = aws_nat_gateway.default[count.index].id
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.default.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

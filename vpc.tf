provider "aws" {
    region = "${var.region}"
    #access_key  = var.aws_access_key_id
    #secret_key  = var.aws_secret_access_key
    
    aws_access_key_id = var.aws_access_key_id
    aws_secret_access_key = var.aws_secret_access_key

}

# VPC resources: This will create 1 VPC with 4 subnets, 1 IGW, 4 RT

resource "aws_vpc" "default" {
    cidr_block = var.cidr_block
    enable_dns_support = true
    enable_dns_hostname = true
}

resource "aws_internet_gateway" "default"{
    vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "private" {
    count = length(var,private_subnet_cidr_blocks)

    vpc_id = aws_vpc.default.vpc_id
    
}

resource "aws_route" "private" {
    count = length(var.private_subnet_cidr_blocks)

    route_table_is = aws_route_table.private[count.index].id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.default[count.index].id

}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.default.id

}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.default.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr_blocks)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

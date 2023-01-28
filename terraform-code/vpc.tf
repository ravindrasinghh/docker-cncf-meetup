resource "aws_vpc" "main" {
  cidr_block           = var.vpc_conf.cidr_block
  instance_tenancy     = var.vpc_conf.instance_tenancy
  enable_dns_hostnames = var.vpc_conf.enable_dns_hostnames
  enable_dns_support   = var.vpc_conf.enable_dns_support
  tags = {
    Name = "${var.env}-${local.project}-vpc"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-${local.project}-igw"
  }
}
resource "aws_subnet" "public_subnet" {
  for_each                = var.public_subnet
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.env}-${local.project}-${each.key}"
  }
}
resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.env}-${local.project}-public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

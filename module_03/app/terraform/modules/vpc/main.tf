resource "aws_vpc" "practice_vpc" {
  cidr_block = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id = aws_vpc.practice_vpc.id
  cidr_block = var.cidr_subnet
  map_public_ip_on_launch = "true"
  availability_zone = var.availability_zone
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.practice_vpc.id
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.practice_vpc.id
route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }
tags = {
    Environment = var.environment_tag
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_subnet" "subnet_private" {
  vpc_id = aws_vpc.practice_vpc.id
  cidr_block = var.private_cidr_subnet
  map_public_ip_on_launch = "false"
  availability_zone = var.private_availability_zone
  tags = {
    Environment = var.environment_tag
  }
}
resource "aws_network_acl" "all" {
    vpc_id = aws_vpc.practice_vpc.id
    egress {
        protocol = "-1"
        rule_no = 2
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    ingress {
         protocol = "-1"
         rule_no = 1
         action = "allow"
         cidr_block = "0.0.0.0/0"
         from_port = 0
         to_port = 0
    }
    tags = {
         Environment = var.environment_tag
    }
}

resource "aws_route_table" "rtb_private" {
  vpc_id = aws_vpc.practice_vpc.id
route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.practice_nat.id
  }
tags = {
    Environment = var.environment_tag
  }
}

resource "aws_route_table_association" "rta_subnet_private" {
  subnet_id      = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.rtb_private.id
}

resource "aws_nat_gateway" "practice_nat" {
    allocation_id = var.eip_id
    subnet_id = aws_subnet.subnet_public.id
    depends_on = ["aws_internet_gateway.igw"]
}
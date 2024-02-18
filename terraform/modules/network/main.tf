resource "aws_vpc" "devops_vpc" {
  cidr_block       = "10.16.0.0/16"
  instance_tenancy = "default"
  tags = {
    "Name" = "devops-vpc"
  }
}

resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id
  tags = {
    "Name" = "devops-igw"
  }
}

resource "aws_subnet" "subnet_web_a" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.16.0.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    "Name"                   = "SubnetWebA"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "subnet_web_b" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.16.16.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    "Name"                   = "SubnetWebB"
    "kubernetes.io/role/elb" = "1"

  }
}

resource "aws_subnet" "subnet_web_c" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.16.32.0/20"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    "Name"                   = "SubnetWebC"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "subnet_app_a" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.16.96.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    "Name" = "SubnetAppA"
  }
}

resource "aws_subnet" "subnet_app_b" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.16.112.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    "Name" = "SubnetAppB"
  }
}

resource "aws_subnet" "subnet_app_c" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.16.128.0/20"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false
  tags = {
    "Name" = "SubnetAppC"
  }
}

resource "aws_route_table" "rt_web" {
  vpc_id = aws_vpc.devops_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }
  tags = {
    "Name" = "devops-vpc-rt-web"
  }
}

resource "aws_route_table" "rt_app" {
  vpc_id = aws_vpc.devops_vpc.id
  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.devops_natgw.id
  # }
  tags = {
    "Name" = "devops-vpc-rt-app"
  }
}

resource "aws_route_table_association" "rt_as_web_a" {
  subnet_id      = aws_subnet.subnet_web_a.id
  route_table_id = aws_route_table.rt_web.id
}

resource "aws_route_table_association" "rt_as_web_b" {
  subnet_id      = aws_subnet.subnet_web_b.id
  route_table_id = aws_route_table.rt_web.id
}

resource "aws_route_table_association" "rt_as_web_c" {
  subnet_id      = aws_subnet.subnet_web_c.id
  route_table_id = aws_route_table.rt_web.id
}

resource "aws_route_table_association" "rt_as_app_a" {
  subnet_id      = aws_subnet.subnet_app_a.id
  route_table_id = aws_route_table.rt_app.id
}

resource "aws_route_table_association" "rt_as_app_b" {
  subnet_id      = aws_subnet.subnet_app_b.id
  route_table_id = aws_route_table.rt_app.id
}

resource "aws_route_table_association" "rt_as_app_c" {
  subnet_id      = aws_subnet.subnet_app_c.id
  route_table_id = aws_route_table.rt_app.id
}

# resource "aws_eip" "devops_eip" {
#   depends_on = [aws_internet_gateway.devops_igw]
# }

# resource "aws_nat_gateway" "devops_natgw" {
#   allocation_id = aws_eip.devops_eip.id
#   depends_on    = [aws_internet_gateway.devops_igw]
#   subnet_id     = aws_subnet.subnet_web_a.id
#   tags = {
#     "Name" = "devops-natgw-a"
#   }
# }

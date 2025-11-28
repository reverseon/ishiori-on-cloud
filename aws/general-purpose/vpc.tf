resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "ishiori-main-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "ishiori-main-internet-gateway"
  }
}

resource "aws_subnet" "apne1a-general-public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 11, 1 * 8 + 0) # 10.0.1.0/27
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "ishiori-apne1a-general-public-subnet"
  }
}

resource "aws_subnet" "apne1a-general-private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 11, 1 * 8 + 1) # 10.0.1.32/27
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "ishiori-apne1a-general-private-subnet"
  }
}

resource "aws_subnet" "apne1c-general-public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 11, 2 * 8 + 0) # 10.0.2.0/27
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "ishiori-apne1c-general-public-subnet"
  }
}

resource "aws_subnet" "apne1c-general-private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 11, 2 * 8 + 1) # 10.0.2.32/27
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "ishiori-apne1c-general-private-subnet"
  }
}

resource "aws_subnet" "apne1d-general-public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 11, 3 * 8 + 0) # 10.0.3.0/27
  availability_zone = "ap-northeast-1d"
  tags = {
    Name = "ishiori-apne1d-general-public-subnet"
  }
}

resource "aws_subnet" "apne1d-general-private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 11, 3 * 8 + 1) # 10.0.3.32/27
  availability_zone = "ap-northeast-1d"
  tags = {
    Name = "ishiori-apne1d-general-private-subnet"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "ishiori-public-route-table"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "apne1a_public" {
  subnet_id      = aws_subnet.apne1a-general-public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "apne1c_public" {
  subnet_id      = aws_subnet.apne1c-general-public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "apne1d_public" {
  subnet_id      = aws_subnet.apne1d-general-public.id
  route_table_id = aws_route_table.public.id
}
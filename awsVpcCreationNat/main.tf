resource "aws_vpc" "test-vpc" {
  cidr_block       = "12.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "test-vpc-public" {
  vpc_id     = aws_vpc.test-vpc.id
  cidr_block = "12.0.1.0/24"
  depends_on  = [aws_vpc.test-vpc]
  tags = {
    Name = "test-vpc-public"
  }
   
   
}

resource "aws_subnet" "test-vpc-private" {
  vpc_id     = aws_vpc.test-vpc.id
  cidr_block = "12.0.2.0/24"
  depends_on  = [aws_vpc.test-vpc]
  tags = {
    Name = "test-vpc-private"
  }
   
   
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.test-vpc.id
  depends_on  = [aws_vpc.test-vpc]
  tags = {
    Name = "test-vpc-gw"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.test-vpc.id

  # since this is exactly the route AWS will create, the route will be adopted

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.test-vpc.id

  # since this is exactly the route AWS will create, the route will be adopted

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
  }
  depends_on  = [aws_nat_gateway.example]
}



resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.test-vpc-public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.test-vpc-private.id
  route_table_id = aws_route_table.private.id
}
resource "aws_default_route_table" "example" {
  default_route_table_id = aws_vpc.test-vpc.default_route_table_id

  route = []

  tags = {
    Name = "example"
  }
}


/*resource "aws_default_route_table" "example" {
  default_route_table_id = aws_vpc.test-vpc.default_route_table_id


route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "default-route-table-test-vpc"
  }
}
*/

resource "aws_eip" "bar" {
  domain = "vpc"
  depends_on                = [aws_internet_gateway.gw]
}


resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.bar.id
  subnet_id     = aws_subnet.test-vpc-public.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}
output test-vpc{
    description = " VPC ARN"
    value = "${aws_vpc.test-vpc.arn}"
}

# Creating the networking infrastructure for EKS Deployment

# Create VPC and IGW (internet gateway)
resource "aws_vpc" "rad-vpc" {
  
  cidr_block           = "10.0.11.0/24"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    key  = "main"
    Name = "r&d-vpc"
  }
}

resource "aws_internet_gateway" "rad-igw" {

  tags = {
    Name = "rad-igw"
  }
  
}

resource "aws_internet_gateway_attachment" "rad-igw-attach" {
  
  vpc_id              = aws_vpc.rad-vpc.id
  internet_gateway_id = aws_internet_gateway.rad-igw.id

}

data "aws_availability_zones" "available" {

    state = "available"
}

# Creating 2 Public Subnets && 4 Private Subnets
resource "aws_subnet" "sn-rad-ngw" {

  vpc_id            = aws_vpc.rad-vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.11.0/28"

  tags = {
    Name = "sn-rad-ngw"
  }
  lllllllllllll
}

resource "aws_subnet" "sn-rad-alb" {

  vpc_id            = aws_vpc.rad-vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.11.16/28"

  tags = {
    Name = "spare"
  }
  
}

resource "aws_subnet" "sn-rad-front-a" {

  vpc_id            = aws_vpc.rad-vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.11.64/26"

  tags = {
    Name = "sn-rad-front-a"
  }
  
}

resource "aws_subnet" "sn-rad-front-b" {
  
  vpc_id            = aws_vpc.rad-vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.0.11.128/26"

  tags = {
    Name = "sn-rad-front-b"
  }
  
}

resource "aws_subnet" "sn-rad-back-a" {
  
  vpc_id            = aws_vpc.rad-vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.11.128/26"

  tags = {
    Name = "sn-rad-front-b"
  }
  
}

# Creating Web route table Web and App
resource "aws_route_table" "rt-rad-web" {

  vpc_id = aws_vpc.rad-vpc.id

  tags = {
    Name = "rt-rad-web"
  }
  
}

resource "aws_route" "rad-default-route-web" {

  route_table_id         = aws_route_table.rt-rad-web.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.rad-igw.id
  
}

# resource "aws_route_table" "rt-rad-app" {
#   vpc_id = aws_vpc.rad-vpc.id

#   tags = {
#     Name = "rt-rad-app"
#   }
  
# }

# resource "aws_route" "rad-default-route-web" {

#   route_table_id         = aws_route_table.rt-rad-web.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.rad-igw.id
  
# }


# Attaching the route table to Web subnets
# df  = default route
# int = Internal
resource "aws_route_table_association" "df-rad-web-a" {

  subnet_id      = aws_subnet.sn-rad-web-a.id
  route_table_id = aws_route_table.rt-rad-web.id

}

resource "aws_route_table_association" "df-rad-web-b" {
  
  subnet_id      = aws_subnet.sn-rad-web-b.id
  route_table_id = aws_route_table.rt-rad-web.id

}

# resource "aws_route_table_association" "int-rad-app-a" {

#   subnet_id      = aws_subnet.sn-rad-app-a.id
#   route_table_id = aws_route_table.rt-rad-app.id
  
# }

# resource "aws_route_table_association" "int-rad-app-b" {

#   subnet_id      = aws_subnet.sn-rad-app-b.id
#   route_table_id = aws_route_table.rt-rad-app.id
  
# }

# Create NAT Gateway with Elastiac IP
# ngw = NAT Gateway

resource "aws_eip" "ngw-eip-web" {

  vpc = true

  tags = {
    Name = "ngw-eip"
  }
  
}

resource "aws_nat_gateway" "ngw-web" {
  
  allocation_id = aws_eip.ngw-eip-web.id
  subnet_id = [ aws_subnet.sn-rad-web-a, aws_subnet.sn-red-web-b ]

}
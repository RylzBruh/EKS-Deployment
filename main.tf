# Creating Network Infarastructure in AWS for AWS EKS Deployment using Terraform 

provider "aws" {
  region = "us-east-1" 
}


# VPC

resource "aws_vpc" "vpc-rad" {
  
  cidr_block = "10.25.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-rad"
  }

}

# Internet Gateway

resource "aws_internet_gateway" "igw-rad" {

  vpc_id = aws_vpc.vpc-rad.id

  tags = {
    Name = "igw-rad"
  }
  
}

# Subnets AZ-A

resource "aws_subnet" "sn-rad-web-A" {

  vpc_id = aws_vpc.vpc-rad.id
  cidr_block = "10.25.0.0/20"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "sn-rad-web-A"
  }

}

resource "aws_subnet" "sn-rad-app-A" {

  vpc_id = aws_vpc.vpc-rad.id
  cidr_block = "10.25.16.0/20"
  availability_zone = "us-east-1a"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "sn-rad-app-A"
  }

}

resource "aws_subnet" "sn-rad-db-A" {

  vpc_id = aws_vpc.vpc-rad.id
  cidr_block = "10.25.32.0/20"
  availability_zone = "us-east-1a"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "sn-rad-db-A"
  }

}

# Subnets AZ-B

resource "aws_subnet" "sn-rad-web-B" {

  vpc_id = aws_vpc.vpc-rad.id
  cidr_block = "10.25.48.0/20"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "sn-rad-web-B"
  }

}

resource "aws_subnet" "sn-rad-app-B" {

  vpc_id = aws_vpc.vpc-rad.id
  cidr_block = "10.25.64.0/20"
  availability_zone = "us-east-1b"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "sn-rad-app-B"
  }

}

resource "aws_subnet" "sn-rad-db-B" {

  vpc_id = aws_vpc.vpc-rad.id
  cidr_block = "10.25.80.0/20"
  availability_zone = "us-east-1b"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "sn-rad-db-B"
  }

}

# Security Groups

resource "aws_security_group" "sg-rad-web" {

  vpc_id = aws_vpc.vpc-rad.id
  name = "sg-rad-web"

  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "sg-rad-web"
  }
    

# NAT Gateway AZ-A

resource "aws_eip" "eip-rad-ngw-A" {

  domain = "vpc"

  tags = {
    Name = "eip-rad-ngw-A"
  }
  

}

resource "aws_nat_gateway" "ngw-rad-A" {

  allocation_id = aws_eip.eip-rad-ngw-A.id
  subnet_id = aws_subnet.sn-rad-web-A.id

  tags = {
    Name = "ngw-rad-A"
  }

}

# NAT Gateway AZ-B

resource "aws_eip" "eip-rad-ngw-B" {

  domain = "vpc"

  tags = {
    Name = "eip-rad-ngw-B"
  }

}

resource "aws_nat_gateway" "ngw-rad-B" {

  allocation_id = aws_eip.eip-rad-ngw-B.id
  subnet_id = aws_subnet.sn-rad-web-B.id

  tags = {
    Name = "ngw-rad-B"
  }

}

# Route Table AZ-A

resource "aws_route_table" "rt-rad-ngw-A" {

  vpc_id = aws_vpc.vpc-rad.id

  tags = {
    Name = "rt-rad-ngw-A"
  }

}

resource "aws_route_table" "rt-rad-privet-A" {

  vpc_id = aws_vpc.vpc-rad.id

  tags = {
    Name = "rt-rad-privet-A"
  }
  
}

# Route Table Association AZ-A

resource "aws_route_table_association" "rta-rad-web-A" {

  count = 1
  subnet_id = element([aws_subnet.sn-rad-web-A.id], count.index)
  route_table_id = aws_route_table.rt-rad-ngw-A.id

}

resource "aws_route_table_association" "rta-rad-app-A" {

  count = 2
  subnet_id = element([aws_subnet.sn-rad-app-A.id, aws_subnet.sn-rad-db-A.id], count.index)
  route_table_id = aws_route_table.rt-rad-privet-A.id

}

# Route Table AZ-B

resource "aws_route_table" "rt-rad-ngw-B" {

  vpc_id = aws_vpc.vpc-rad.id

  tags = {
    Name = "rt-rad-ngw-B"
  }

}

resource "aws_route_table" "rt-rad-privet-B" {

  vpc_id = aws_vpc.vpc-rad.id

  tags = {
    Name = "rt-rad-privet-B"
  }
  
}

# Route Table Association AZ-B

resource "aws_route_table_association" "rta-rad-web-B" {

  count = 1
  subnet_id = element([aws_subnet.sn-rad-web-B.id], count.index)
  route_table_id = aws_route_table.rt-rad-ngw-B.id

}

resource "aws_route_table_association" "rta-rad-app-B" {

  count = 2
  subnet_id = element([aws_subnet.sn-rad-app-B.id, aws_subnet.sn-rad-db-B.id], count.index)
  route_table_id = aws_route_table.rt-rad-privet-B.id

}

# Route AZ-A

resource "aws_route" "r-rad-ngw-A" {

  route_table_id = aws_route_table.rt-rad-ngw-A.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw-rad.id

}

resource "aws_route" "r-rad-privet-A" {

  route_table_id = aws_route_table.rt-rad-privet-A.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.ngw-rad-A.id

}

# Route AZ-B

resource "aws_route" "r-rad-ngw-B" {

  route_table_id = aws_route_table.rt-rad-ngw-B.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw-rad.id

}

resource "aws_route" "r-rad-privet-B" {

  route_table_id = aws_route_table.rt-rad-privet-B.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.ngw-rad-B.id

}

# EKS Cluster

resource "aws_eks_cluster" "eks-rad" {

  name = "eks-rad"
  role_arn = aws_iam_role.iam-rad-eks-cp.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.sn-rad-app-A.id,
      aws_subnet.sn-rad-app-B.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.ipa-rad-eks
  ]

  tags = {
    Name = "eks-rad"
  }

}

# IAM Role Cluster

resource "aws_iam_role" "iam-rad-eks-cp" {

  name = "iam-rad-eks"
  assume_role_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "eks.amazonaws.com"
          },
          "Action": [
            "sts:AssumeRole"
          ]
        }
      ]
    }
    EOF
  
  tags = {
    Name = "iam-rad-eks-cp"
  }

}

resource "aws_iam_role_policy_attachment" "ipa-rad-eks" {

  role = aws_iam_role.iam-rad-eks-cp.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  
}

# IAM role EKS Worker Nodes

resource "aws_iam_role" "iam-rad-eks-ng" {

  name = "iam-rad-eks-ng"
  assume_role_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Action": [
            "sts:AssumeRole"
          ]
        }
      ]
    }
    EOF
  
  tags = {
    Name = "iam-rad-eks-ng"
  }

}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {

  role = aws_iam_role.iam-rad-eks-ng.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  
}

resource "aws_iam_role_policy_attachment" "ecr_read_only_policy" {

  role = aws_iam_role.iam-rad-eks-ng.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {

  role = aws_iam_role.iam-rad-eks-ng.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  
}

# EKS Node Group AZ-A

resource "aws_eks_node_group" "eks-rad-ng-A" {

  cluster_name = aws_eks_cluster.eks-rad.name
  node_group_name = "eks-rad-ng-A"
  node_role_arn = aws_iam_role.iam-rad-eks-ng.arn
  subnet_ids = [
    aws_subnet.sn-rad-app-A.id
  ]
  scaling_config {
    desired_size = 1
    max_size = 3
    min_size = 1
  }
  depends_on = [
    aws_eks_cluster.eks-rad
  ]

  tags = {
    Name = "eks-rad-ng-A"
  }

}

# EKS Node Group AZ-B

resource "aws_eks_node_group" "eks-rad-ng-B" {

  cluster_name = aws_eks_cluster.eks-rad.name
  node_group_name = "eks-rad-ng-B"
  node_role_arn = aws_iam_role.iam-rad-eks-ng.arn
  subnet_ids = [
    aws_subnet.sn-rad-app-B.id
  ]
  scaling_config {
    desired_size = 1
    max_size = 3
    min_size = 1
  }
  depends_on = [
    aws_eks_cluster.eks-rad
  ]

  tags = {
    Name = "eks-rad-ng-B"
  }

}

# Output

output "eks_cluster_name" {
  value = aws_eks_cluster.eks-rad.name
}

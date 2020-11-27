##############################
# Aws Provider
##############################
provider "aws" {
  
  region = "us-east-1"
  profile = "default"
}



##############################
# VPC creation
##############################
resource "aws_vpc" "vpc_k8" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "My VPC"
  }
}


##############################
# Private Subnet Creation
##############################
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.vpc_k8.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Isolated Private Subnet"
  }
}


##############################
# Routing Table
##############################
resource "aws_route_table" "vpc_k8_us_east_1a_private" {
    vpc_id = aws_vpc.vpc_k8.id

    tags = {
        Name = "Local Route Table for Isolated Private Subnet"
    }
}

resource "aws_route_table_association" "vpc_k8_us_east_1a_private" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.vpc_k8_us_east_1a_private.id
}


##############################
# Security Group for k8s
##############################
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_sg"
  description = "Allow SSH inbound connections"
  vpc_id = aws_vpc.vpc_k8.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_sg"
  }
}


##############################
# Security Group for mongodb
##############################
resource "aws_security_group" "mongo_sg" {
  name        = "allow_ssh_sg"
  description = "Allow SSH inbound connections"
  vpc_id = aws_vpc.vpc_k8.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mongo_sg"
  }
}


##############################
# K8s Master Node
##############################
resource "aws_instance" "master_k8s" {
  ami           = "ami-0ac019f4fcb7cb7e6"
  instance_type = "t2.medium"
  key_name = "k8s_key"
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  subnet_id = aws_subnet.private.id
  associate_public_ip_address = true

  tags = {
    Name = "Master Node k8s"
  }
}


##############################
# K8s Worker1 Node
##############################
resource "aws_instance" "worker1_k8s" {
  ami           = "ami-0ac019f4fcb7cb7e6"
  instance_type = "t2.medium"
  key_name = "k8s_key"
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  subnet_id = aws_subnet.private.id
  associate_public_ip_address = true

  tags = {
    Name = "Worker1 Node k8s"
  }
}


##############################
# K8s Worker2 Node
##############################
resource "aws_instance" "worker2_k8s" {
  ami           = "ami-0ac019f4fcb7cb7e6"
  instance_type = "t2.medium"
  key_name = "k8s_key"
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  subnet_id = aws_subnet.private.id
  associate_public_ip_address = true

  tags = {
    Name = "Worker2 Node k8s"
  }
}


##############################
# Mongodb Cluster Instance1
##############################
resource "aws_instance" "mongo1" {
  ami           = "ami-0ac019f4fcb7cb7e6"
  instance_type = "t2.medium"
  key_name = "k8s_key"
  vpc_security_group_ids = [ aws_security_group.mongo_sg.id ]
  subnet_id = aws_subnet.private.id
  associate_public_ip_address = true

  tags = {
    Name = "Mongo_Node1"
  }
}

##############################
# Mongodb Cluster Instance2
##############################
resource "aws_instance" "mongo2" {
  ami           = "ami-0ac019f4fcb7cb7e6"
  instance_type = "t2.medium"
  key_name = "k8s_key"
  vpc_security_group_ids = [ aws_security_group.mongo_sg.id ]
  subnet_id = aws_subnet.private.id
  associate_public_ip_address = true

  tags = {
    Name = "Mongo Node2"
  }
}

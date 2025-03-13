resource "aws_vpc" "lab7_vpc" {
    cidr_block = "10.7.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
  
    tags = {
        Project = "lab7"
        Name = "lab7-vpc"
    }
}

resource "aws_subnet" "lab7_private_subnet1" {
    vpc_id = aws_vpc.lab7_vpc.id
    cidr_block = "10.7.1.0/24"
    availability_zone = "eu-north-1a"

    tags = {
        Name = "lab7-private-subnet1"
        Project = "lab7"
    }
}

resource "aws_subnet" "lab7_private_subnet2" {
    vpc_id = aws_vpc.lab7_vpc.id
    cidr_block = "10.7.2.0/24"
    availability_zone = "eu-north-1b"

    tags = {
        Name = "lab7-private-subnet2"
        Project = "lab7"
    }
}

resource "aws_route_table" "lab7_private_route_table" {
  vpc_id = aws_vpc.lab7_vpc.id

  tags = {
    Project = "lab7"
    Name = "lab7-private-route-table"
  }  
}

resource "aws_route_table_association" "lab7_private_route_table_association1" {
  subnet_id = aws_subnet.lab7_private_subnet1.id
  route_table_id = aws_route_table.lab7_private_route_table.id
}

resource "aws_route_table_association" "lab7_private_route_table_association2" {
  subnet_id = aws_subnet.lab7_private_subnet2.id
  route_table_id = aws_route_table.lab7_private_route_table.id
}

resource "aws_vpc_endpoint" "lab7_s3_endpoint" {
  vpc_id = aws_vpc.lab7_vpc.id
  service_name = "com.amazonaws.eu-north-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [ aws_route_table.lab7_private_route_table.id ]

  tags = {
    Project = "lab7"
    Name = "lab7-s3-endpoint"
  }  
}

resource "aws_vpc_endpoint" "lab7_ecr_api_endpoint" {
  vpc_id = aws_vpc.lab7_vpc.id
  service_name =  "com.amazonaws.eu-north-1.ecr.api"
  vpc_endpoint_type = "Interface"
  security_group_ids = [ aws_security_group.lab7_private_sg.id ]
  subnet_ids = [ aws_subnet.lab7_private_subnet1.id, aws_subnet.lab7_private_subnet2.id ]
  private_dns_enabled = true

  tags = {
    Project = "lab7"
    Name = "lab7-ecr-endpoint-api"
  }
}

resource "aws_vpc_endpoint" "lab7_ecr_dkr_endpoint" {
  vpc_id = aws_vpc.lab7_vpc.id
  service_name =  "com.amazonaws.eu-north-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  security_group_ids = [ aws_security_group.lab7_private_sg.id ]
  subnet_ids = [ aws_subnet.lab7_private_subnet1.id, aws_subnet.lab7_private_subnet2.id ]
  private_dns_enabled = true

  tags = {
    Project = "lab7"
    Name = "lab7-ecr-endpoint-dkr"
  }  
}

resource "aws_security_group" "lab7_private_sg" {
  name = "lab7-private-sg"
  description = "A Security Group for ensuring no connections to/from outside are allowed, with the exception of outbound access to s3"
  vpc_id = aws_vpc.lab7_vpc.id  

  tags = {
    Project = "lab7"
  }  
}

resource "aws_vpc_security_group_egress_rule" "lab7_private_sg_egress" {
  security_group_id = aws_security_group.lab7_private_sg.id

  referenced_security_group_id = aws_security_group.lab7_private_sg.id
  ip_protocol = -1
}

resource "aws_vpc_security_group_ingress_rule" "lab7_private_sg_ingress" {
  security_group_id = aws_security_group.lab7_private_sg.id

  referenced_security_group_id = aws_security_group.lab7_private_sg.id
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "lab7_private_sg_s3_egress" {
  security_group_id = aws_security_group.lab7_private_sg.id

  prefix_list_id = "pl-c3aa4faa"
  ip_protocol = "TCP"
  from_port = 443
  to_port = 443
}
resource "aws_vpc" "lab7_vpc" {
    cidr_block = "10.7.0.0/16"
  
    tags = {
        Project = "lab7"
    }
}

resource "aws_subnet" "lab7_subnet1" {
    vpc_id = aws_vpc.lab7_vpc.id
    cidr_block = "10.7.1.0/24"
    availability_zone = "eu-north-1a"

    tags = {
        Project = "lab7"
    }
}

resource "aws_subnet" "lab7_subnet2" {
    vpc_id = aws_vpc.lab7_vpc.id
    cidr_block = "10.7.2.0/24"
    availability_zone = "eu-north-1b"
    map_public_ip_on_launch = true

    tags = {
        Project = "lab7"
    }
}

resource "aws_internet_gateway" "lab7_internet_gateway" {
  vpc_id = aws_vpc.lab7_vpc.id
  
  tags = {
    Project = "lab7"
  }
}

resource "aws_default_route_table" "lab7_route_table" {
    default_route_table_id = aws_vpc.lab7_vpc.id

    route {
        cidr_block = "10.7.0.0/16"
        gateway_id = "local"
    }

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.lab7_internet_gateway.id
    }  

    tags = {
        Project = "lab7"
    } 
}

resource "aws_vpc_endpoint" "lab7_s3_endpoint" {
  vpc_id = aws_vpc.lab7_vpc.id
  service_name = "com.amazonaws.eu-north-1.s3"
}
# i might need aws_vpc_endpoint_route_table_association

# resource "aws_security_group" "lab7_s3_sg" {
#   name = "lab7-s3-sg"
#   description = "A Security Group to allow access to private S3"
#   vpc_id = aws_vpc.lab7_vpc.id
  

#   tags = {
#     Project = "lab7"
#   }
# }

resource "aws_security_group" "lab7_alb_sg" {
  name = "lab7-alb-sg"
  description = "A Security Group to allow public access to ALB"
  vpc_id = aws_vpc.lab7_vpc.id
  

  tags = {
    Project = "lab7"
  }
}

resource "aws_vpc_security_group_ingress_rule" "lab7_alb_sg_ingress" {
  security_group_id = aws_security_group.lab7_alb_sg.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 443
  to_port = 443
  ip_protocol = "TCP"
}

resource "aws_security_group" "lab7_ecs_sg" {
  name = "lab7-ecs-sg"
  description = "A Security Group to allow access from the ALB to the ecs tasks"
  vpc_id = aws_vpc.lab7_vpc.id  

  tags = {
    Project = "lab7"
  }
}

resource "aws_vpc_security_group_ingress_rule" "lab7_ecs_sg_ingress" {
  security_group_id = aws_security_group.lab7_ecs_sg.id

  referenced_security_group_id = aws_security_group.lab7_alb_sg.id
  ip_protocol = "TCP"
  from_port = 8080
  to_port = 8080
}

resource "aws_security_group" "lab7_private_sg" {
  name = "lab7-private-sg"
  description = "A Security Group for ensuring no connections to/from outside are allowed"
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
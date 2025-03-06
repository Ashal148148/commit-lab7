resource "aws_instance" "lab7_linux" {
  ami = "ami-016038ae9cc8d9f51"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.lab7_subnet1.id
  security_groups = [ aws_security_group.lab7_private_sg.name ]
  private_ip = "10.7.1.1"

  tags = {
    Project = "lab7"
  } 
}

resource "aws_instance" "lab7_windows" {
  ami = "ami-0e0d6e610ffe146fe"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.lab7_subnet1.id
  security_groups = [ aws_security_group.lab7_private_sg.name ]
  private_ip = "10.7.1.2"

  tags = {
    Project = "lab7"
  } 
}

resource "aws_ecs_cluster" "lab7_ecs" {
  name = "lab7-ecs"

  tags = {
    Project = "lab7"
  } 
}

resource "aws_ecs_cluster_capacity_providers" "name" {
  cluster_name = aws_ecs_cluster.lab7_ecs.name

  capacity_providers = [ "FARGATE" ]
}

resource "aws_ecs_task_definition" "lab7_website_task" {
    family = "service"
    # if i end up using AWS ECR ill need to add ecs_execution_role iam 
    container_definitions = jsonencode([
        {
            name = "lab7-website"
            image = "ashal148148/lab7-website"
            requires_compatibilities = ["FARGATE"]
            essential = true
            cpu       = 10
            memory    = 512
            portMappings = [
                {
                    containerPort = 8080
                    hostPort = 443
                    protocol = "tcp"
                }
            ]
        }
    ])  
    task_role_arn = aws_iam_role.lab7_ecs_s3_role.arn
}

resource "aws_lb" "lab7_lb" {
    name = "lab7-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = [ aws_security_group.lab7_alb_sg.id ]
    subnets = [ aws_subnet.lab7_subnet2.id ]

    enable_deletion_protection = false

    tags = {
      Project = "lab7"
    }  
}

resource "aws_lb_target_group" "lab7_website_lb_tg" {
  name = "lab7-website-lb-tg"
  port = 8080
  protocol = "HTTP"
  vpc_id = aws_vpc.lab7_vpc.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lab7_lb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = aws_acm_certificate.lab7_cert.arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lab7_website_lb_tg.arn
  }
}

resource "aws_ecs_service" "lab7_website_service" {
    name = "lab7-website"
    cluster = aws_ecs_cluster.lab7_ecs.id
    task_definition = aws_ecs_task_definition.lab7_website_task.arn
    desired_count = 2
    iam_role = aws_iam_role.lab7_ecs_s3_role.arn
    depends_on = [ aws_iam_policy.lab7_s3_policy ]

    network_configuration {
    subnets          = [aws_subnet.lab7_subnet1.id, aws_subnet.lab7_subnet2.id]
    security_groups = [ aws_security_group.lab7_ecs_sg.id ] 
    assign_public_ip = true
  }
  
    load_balancer {
      target_group_arn = aws_lb_target_group.lab7_website_lb_tg.arn
      container_name = "lab7-website"
      container_port = 8080
    }
}
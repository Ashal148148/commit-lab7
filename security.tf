resource "aws_iam_policy" "lab7_s3_policy" {
  name = "lab7-s3-read"
  description = "Allow object get on lab7 S3 object"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "s3:GetObject"
            ]
            Resource = [ "${aws_s3_bucket.lab7_s3.arn}/*" ]
        }
    ]
  })

  tags = {
    Project = "lab7"
  }
}
# might want to add access to cloudwatch for logs to the ECS task role ("logs:CreateLogStream", "logs:PutLogEvents")
resource "aws_iam_role" "lab7_ecs_s3_role" {
  name = "lab7-ecs-s3-role"
  description = "Role that is given to ECS task to allow access to an S3 bucket"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Sid = ""
            Action = "sts:AssumeRole"
            Principal = {
                "Service": [
                    "ecs-tasks.amazonaws.com"
                ]
            }
        }
    ]
  })

  tags = {
    Project = "lab7"
  }
}

resource "aws_iam_role_policy_attachment" "lab7_attach_s3_policy" {
  role = aws_iam_role.lab7_ecs_s3_role.name
  policy_arn = aws_iam_policy.lab7_s3_policy.arn
}
# might wanna split this policy to one policy that allows to generate an access token to all ECR 
# and another that allows to get images only from the relevant registry
resource "aws_iam_policy" "lab7_ecr_policy" {
  name = "lab7-ecr-pull"
  description = "Allow ECS to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetAuthorizationToken",
                "ecr:GetDownloadUrlForLayer",
            ]
            Resource = [ "${aws_ecr_repository.lab7_ecr_registry.arn}", "*" ]
        }
    ]
  })
  tags = {
    Project = "lab7"
  }
}

resource "aws_iam_role" "lab7_ecs_ecr_role" {
  name = "lab7-ecs-ecr-role"
  description = "Allow ECS tasks to pull images from ECR ashal148148/lab7-website repository"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Sid = ""
            Action = "sts:AssumeRole"
            Principal = {
                "Service": [
                    "ecs-tasks.amazonaws.com"
                ]
            }
        }
    ]
  })

  tags = {
    Project = "lab7"
  }
}

resource "aws_iam_role_policy_attachment" "lab7_attach_ecr_policy" {
  role = aws_iam_role.lab7_ecs_ecr_role.name
  policy_arn = aws_iam_policy.lab7_ecr_policy.arn
}
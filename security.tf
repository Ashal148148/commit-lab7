resource "aws_iam_policy" "lab7_s3_policy" {
  name = "lab7_s3_read"
  description = "Allow read on lab7 S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "s3:GetObject"
            ]
            Resource = [ "${aws_s3_bucket.lab7_s3.arn}/*" ]
            Principal = "*"
        }
    ]
  })
}

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
}

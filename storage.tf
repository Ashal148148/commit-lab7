resource "aws_s3_bucket" "lab7_s3" {
  bucket = "ashal-lab7-s3" # the name lab7-s3 was taken so i added my nickname to the name

  tags = {
        Project = "lab7"
  }
}

resource "aws_s3_object" "lab7_s3_logo1" {
  bucket = aws_s3_bucket.lab7_s3.bucket
  key = "logo.png"
  source = "logo.png"
}

resource "aws_s3_object" "lab7_s3_logo2" {
  bucket = aws_s3_bucket.lab7_s3.bucket
  key = "logo192.png"
  source = "logo192.png"
}

resource "aws_ecr_repository" "lab7_ecr_registry" {
  name = "ashal148148/lab7-website"
  image_tag_mutability = "MUTABLE"

  tags = {
    Project = "lab7"
  }
}
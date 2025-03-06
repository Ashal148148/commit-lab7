resource "aws_s3_bucket" "lab7_s3" {
  bucket = "lab7-s3"

  tags = {
        Project = "lab7"
  }
}
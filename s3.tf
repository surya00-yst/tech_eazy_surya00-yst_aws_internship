data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "archive_bucket" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = false
  }

  lifecycle_rule {
    id      = "expire-logs"
    enabled = true
    prefix  = "app/logs/"
    expiration {
      days = 7
    }
  }
}

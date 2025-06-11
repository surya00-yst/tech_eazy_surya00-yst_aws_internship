# IAM roles and policies
variable "bucket_name" {
  type = string
}

resource "aws_iam_role" "s3_readonly" {
  name = "s3_readonly_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy_attachment" "attach_readonly" {
  name       = "attach_s3_readonly_to_role"
  roles      = [aws_iam_role.s3_readonly.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role" "s3_writeonly" {
  name = "s3_writeonly_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "s3_write_policy" {
  name = "s3_writeonly_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:CreateBucket",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      Resource = [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }]
  })
}

resource "aws_iam_policy_attachment" "attach_writeonly" {
  name       = "attach_s3_write_policy"
  roles      = [aws_iam_role.s3_writeonly.name]
  policy_arn = aws_iam_policy.s3_write_policy.arn
}

resource "aws_iam_instance_profile" "write_profile" {
  name = "s3-write-profile"
  role = aws_iam_role.s3_writeonly.name
}

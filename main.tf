variable "bucket_name" {
  type = string
}

resource "aws_instance" "log_uploader" {
  ami           = "ami-0c94855ba95c71c99" # example for Amazon Linux 2
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.write_profile.name

  user_data = file("ec2_userdata.sh")

  tags = {
    Name = "log-uploader"
  }
}

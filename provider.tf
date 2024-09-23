provider "aws" {
  region  = "us-east-1"
  profile = "terraform-dev"
}
resource "aws_key_pair" "my_key_pair" {
  key_name   = "Terraform-Project"
  public_key = file("~/.ssh/my_aws_key.pub")
}

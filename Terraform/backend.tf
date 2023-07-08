# store the terraform state file in s3
terraform {
  backend "s3" {
    bucket    = "terraform-backend-5july"
    key       =  "project.tfstate"
    region    =  "us-east-1"
#    profile   =  "
  }
}
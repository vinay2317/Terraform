# configure aws provider to establish a secure connection between terraform and aws
provider "aws" {
  region  = var.region
  profile = 

  default_tags {
    tags = {
      "Automation"  = 
      "Project"     = 
      "Environment" = 
    }
  }
}
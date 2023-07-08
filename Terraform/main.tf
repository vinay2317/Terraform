#Terraform Block
terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure aws provider
provider "aws" {
    region = var.region
    profile = "default"
}

# Create VPC 
module "vpc" {
    source                       = "./Project/Terraform-vpc-module"
    region                       = var.region
    project_name                 = var.project_name
    environment                  = var.environment
    vpc_cidr                     = var.vpc_cidr
    public_subnet_az1_cidr       = var.public_subnet_az1_cidr
    public_subnet_az2_cidr       = var.public_subnet_az2_cidr
    private_app_subnet_az1_cidr  = var.private_app_subnet_az1_cidr
    private_app_subnet_az2_cidr  = var.private_app_subnet_az2_cidr
    private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
    private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr
}

# Create a Net gateway
module "nat_gateway" {
    source                        = "./Project/Terraform-natgateway-module"
    public_subnet_az1_id          =   module.vpc.public_subnet_az1_id           
    internet_gateway              =   module.vpc.internet_gateway
    public_subnet_az2_id          =   module.vpc.public_subnet_az2_id
    vpc_id                        =   module.vpc.vpc_id
    private_app_subnet_az1_id     =   module.vpc.private_app_subnet_az1_id
    private_data_subnet_az1_id    =   module.vpc.private_data_subnet_az1_id
    private_app_subnet_az2_id     =   module.vpc.private_app_subnet_az2_id
    private_data_subnet_az2_id    =   module.vpc.private_data_subnet_az2_id
}

# Create a Security Group 
module "security_group" {
    source                        = "./Project/Terraform-sg-module"
    vpc_id                        =  module.vpc.vpc_id
    project_name                  =  module.vpc.project_name
    environment                   =  module.vpc.environment
}

#create a ACM 
module "acm" {
  source             = "./Project/Terraform-acm-module"
  domain_name        = var.domain_name
  alternative_names  = var.alternative_names
}




# Create application Load balancer
module "application_load_balancer" {
  source = "./Project/Terraform-alb-module"
  project_name             = module.vpc.project_name
  environment              = module.vpc.environment
  alb_security_group_id    = module.security_group.alb_security_group_id
  public_subnet_az1_id     = module.vpc.public_subnet_az1_id
  public_subnet_az2_id     = module.vpc.public_subnet_az2_id
  vpc_id                   = module.vpc.vpc_id
  certificate_arn          = module.acm.certificate_arn
}


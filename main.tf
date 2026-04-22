provider "aws" {
  region = var.aws_region
}

# 1. Setup the Network
module "networking" {
  source             = "./modules/vpc"
  project_name       = var.project_name
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# 2. Setup the Database (using VPC outputs)
module "database" {
  source            = "./modules/rds"
  project_name      = var.project_name
  vpc_id            = module.networking.vpc_id
  db_subnet_ids     = module.networking.private_app_subnet_ids
  db_password       = var.db_password
}

# 3. Setup Compute (using VPC and Database outputs)
module "compute" {
  source             = "./modules/compute"
  project_name       = var.project_name
  vpc_id             = module.networking.vpc_id
  public_subnets     = module.networking.public_subnet_ids
  private_subnets    = module.networking.private_app_subnet_ids
  db_endpoint        = module.database.db_endpoint
}
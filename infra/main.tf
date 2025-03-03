provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

module "vpc_primary" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  region = "us-east-1"
}

module "eks_primary" {
  source = "./modules/eks"
  vpc_id = module.vpc_primary.vpc_id
  subnet_ids = module.vpc_primary.private_subnet_ids
  region = "us-east-1"
}

module "rds_primary" {
  source = "./modules/rds"
  vpc_id = module.vpc_primary.vpc_id
  subnet_ids = module.vpc_primary.private_subnet_ids
  region = "us-east-1"
}

module "redis_primary" {
  source = "./modules/redis"
  vpc_id = module.vpc_primary.vpc_id
  region = "us-east-1"
}

module "istio_primary" {
  source = "./modules/istio"
  eks_cluster_name = module.eks_primary.eks_cluster_name
  region = "us-east-1"
}

module "vpc_secondary" {
  source = "./modules/vpc"
  cidr_block = "10.1.0.0/16"
  region = "us-west-2"
  providers = {
    aws = aws.west
  }
}

module "eks_secondary" {
  source = "./modules/eks"
  vpc_id = module.vpc_secondary.vpc_id
  subnet_ids = module.vpc_secondary.private_subnet_ids
  region = "us-west-2"
  providers = {
    aws = aws.west
  }
}

module "rds_secondary" {
  source = "./modules/rds"
  vpc_id = module.vpc_secondary.vpc_id
  subnet_ids = module.vpc_secondary.private_subnet_ids
  region = "us-west-2"
  providers = {
    aws = aws.west
  }
}

module "redis_secondary" {
  source = "./modules/redis"
  vpc_id = module.vpc_secondary.vpc_id
  region = "us-west-2"
  providers = {
    aws = aws.west
  }
}

module "istio_secondary" {
  source = "./modules/istio"
  eks_cluster_name = module.eks_secondary.eks_cluster_name
  region = "us-west-2"
  providers = {
    aws = aws.west
  }
}

module "route53" {
  source = "./modules/route53"
  primary_rds_endpoint = module.rds_primary.rds_endpoint
  secondary_rds_endpoint = module.rds_secondary.rds_endpoint
  primary_region = "us-east-1"
  secondary_region = "us-west-2"
}

module "backup" {
  source = "./modules/backup"
  rds_instance_id = module.rds_primary.rds_instance_id
  region = "us-east-1"
}

module "lambda" {
  source = "./modules/lambda"
  primary_rds_instance_id = module.rds_primary.rds_instance_id
  secondary_rds_instance_id = module.rds_secondary.rds_instance_id
  region = "us-east-1"
}
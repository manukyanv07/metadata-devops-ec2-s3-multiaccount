terraform {
  backend "s3" {
    key = "terraform-main.tfstate"
  }
}
data "aws_region" "current" {}
module "vpc" {
  source = "../modules/application/vpc"

  cidr_block           = "10.112.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

module "private_subnets" {
  source = "../modules/application/private-subnets"

  vpc_id             = module.vpc.vpc_id
  cidr_block         = "10.112.16.0/20"
  subnet_count       = 2
  availability_zones = ["us-east-1a", "us-east-1b"]
}

resource "aws_vpc_endpoint" "ssm" {
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.private_subnets.subnet_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [module.ec2.security_group_id]
  tags = {
    Name = "ssm"
  }
}
resource "aws_vpc_endpoint" "ssmmessages" {
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.private_subnets.subnet_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [module.ec2.security_group_id]
  tags = {
    Name = "ssmmessages"
  }
}
resource "aws_vpc_endpoint" "ec2messages" {
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.private_subnets.subnet_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [module.ec2.security_group_id]
  tags = {
    Name = "ec2messages"
  }
}

resource "aws_vpc_endpoint" "sts-direct" {
  service_name        = "com.amazonaws.${data.aws_region.current.name}.sts"
  vpc_id              = module.vpc.vpc_id
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.private_subnets.subnet_ids
  security_group_ids  = [module.ec2.security_group_id]
  tags = {
    Name = "sts-direct"
  }
}

resource "aws_vpc_endpoint" "s3-direct" {
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_id            = module.vpc.vpc_id
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.private_subnets.route_table_ids
  tags = {
    Name = "s3-direct"
  }
}

module "ec2" {
  source                     = "../modules/application/ec2"
  subnet_id                  = module.private_subnets.subnet_ids[0]
  vpc_id                     = module.vpc.vpc_id
  vpc_cidr_block             = module.vpc.vpc_cidr_block
  env                        = var.environment
  storage_bucket_access_role = var.storage_bucket_access_role
}
terraform {
  backend "s3" {
    key = "terraform-main.tfstate"
  }
}

module "website_s3_bucket" {
  source                = "../modules/storage"
  bucket_name           = "${var.environment}-terraform-multi-account-ec2-s3-demo"
  s3_access_caller_role = var.s3_access_caller_role
}

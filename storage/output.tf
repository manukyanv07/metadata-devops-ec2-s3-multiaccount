output "s3_access_role" {
  value = module.website_s3_bucket.role_arn
}
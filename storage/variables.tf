variable "region" {
  type        = string
  description = "The AWS region."
}

variable "environment" {
  type        = string
  description = "Environment name."
}

variable "account_id" {
  type        = string
  description = "AWS Account ID number of the account."
}

variable "profile" {
  type        = string
  description = "AWS Credentials profile"
}
variable "s3_access_caller_role" {}
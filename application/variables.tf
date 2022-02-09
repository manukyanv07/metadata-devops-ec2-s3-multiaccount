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

variable "storage_bucket_access_role" {

}

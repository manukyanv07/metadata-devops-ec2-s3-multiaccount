resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Provider = "Terraform"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "AWS"
      identifiers = [var.s3_access_caller_role]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "ec2_s3_demo_bucket_access_role" {
  name = "ec2_s3_demo_bucket_access_role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Provider = "Terraform"
  }
}


resource "aws_iam_role_policy" "access_policy" {
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        "Sid": "AllowAccountLevelS3Actions",
        "Effect": "Allow",
        "Action": [
          "s3:GetBucketLocation",
          "s3:GetAccountPublicAccessBlock",
          "s3:ListAccessPoints",
          "s3:ListAllMyBuckets"
        ],
        "Resource": "arn:aws:s3:::*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket",
        ],
        "Resource" : [
          "arn:aws:s3:::${var.bucket_name}/*",
          "arn:aws:s3:::${var.bucket_name}"
        ]
      }
    ]
  })
  role = aws_iam_role.ec2_s3_demo_bucket_access_role.id
  tags = {
    Provider = "Terraform"
  }
}


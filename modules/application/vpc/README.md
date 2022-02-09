# terraform-aws-vpc-modules vpc

Creates a VPC.

## Usage

```hcl
module "vpc" {
  source  = "modules/application/vpc"

  cidr_block           = "10.112.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}
```

## Outputs
`vpc_id`  The VPC ID

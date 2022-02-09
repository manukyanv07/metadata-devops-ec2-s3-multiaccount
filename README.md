#Requirements
 - 2 aws accounts "Application" and "Storage"
 - Install ssm plugin manager in your local computer
https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe
 - If you are working from Windows install Make http://gnuwin32.sourceforge.net/install.html

# Create IAC User
Log into your AWS console and create IAC user on each account. For simplicity give the user `PowerUserAccess` and `IAMFullAccess` permissions

Generate access tokens for your IAC user

# AWS Cli configuration
for each user tokens run

`aws configure --profile application`

`aws configure --profile storage`

complete each step with credentials generated for each user.

# TERRAFORM backend 
on each account generate a bucket where terraform will store the state.

in `<account>/dev/backend.conf` change the bucket name with the backend bucket that you have created.
do that for each account.

# Terraform account configuration
In `application/dev/terraform.tfvars` 
- change the `APPLICATION_ACCOUNT_ID` with your applications Account id
- change the `STORAGE_ACCOUNT_ID` with the storage account id
```terraform
account_id                 = "<APPLICATION_ACCOUNT_ID>"
storage_bucket_access_role = "arn:aws:iam::<STORAGE_ACCOUNT_ID>:role/ec2_s3_demo_bucket_access_role"
```

Go to your `storage/dev/terraform.tfvars` and modify
- change the `APPLICATION_ACCOUNT_ID` with your applications Account id
- change the `STORAGE_ACCOUNT_ID` with the storage Account id
```terraform
account_id            = "<STORAGE_ACCOUNT_ID>"
s3_access_caller_role = "arn:aws:iam::APPLICATION_ACCOUNT_ID:role/test-ssm-ec2"
```

# Plan your infrastructure
## Application infra
```shell
cd application
make tf-apply env=dev
```
copy the instance id from output.
## Storage infra
```shell
cd storage
make tf-apply env=dev
```

# Verify

#Verify
Once all infra is created. let's log into our ec2 instance using ssm 

```shell
aws ssm start-session --target <instance-id-from-terraform-output> --profile application --region us-east-1 
```

## Test s3 private connection 

```shell
traceroute -n -T -p 443 s3.amazonaws.com 
traceroute to s3.amazonaws.com (52.216.204.93), 30 hops max, 60 byte packets
1  * * *
2  * * *
3  * * *
4  * * *
5  * * *
6  * * *
7  52.216.204.93  0.662 ms  0.668 ms  0.637 ms
```
You should see something like that.

## Test s3 bucket access.
Upload a random file to your s3 bucket then run

```shell
aws s3 ls s3://dev-terraform-multi-account-ec2-s3-demo --profile storage_profile
2022-02-09 13:05:12      75558 YOURUPLOADED_FILE.file
```
You should see something like that.
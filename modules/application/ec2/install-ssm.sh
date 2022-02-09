#!/bin/bash
cd /tmp
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl start amazon-ssm-agent

sudo mkdir /home/ec2-user/.aws/
sudo cat > /home/ec2-user/.aws/config <<EOL
[profile storage_profile]
role_arn = ${storage_bucket_access_role}
region=us-east-1
credential_source = Ec2InstanceMetadata
sts_regional_endpoints=regional
EOL
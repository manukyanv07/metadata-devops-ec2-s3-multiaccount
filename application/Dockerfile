FROM centos
RUN cd /tmp
RUN yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
RUN systemctl enable amazon-ssm-agent
RUN systemctl start amazon-ssm-agent
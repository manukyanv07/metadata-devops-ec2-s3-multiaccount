#Instance Role
resource "aws_iam_role" "test_role" {
  name               = "test-ssm-ec2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name        = "test-ssm-ec2"
    createdBy   = "MaureenBarasa"
    Owner       = "DevSecOps"
    Project     = "test-terraform"
    environment = "test"
  }
}

resource "aws_iam_policy" "s3_cross_access_policy" {
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Action" : "sts:AssumeRole",
      "Resource" :  "${var.storage_bucket_access_role}"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = aws_iam_policy.s3_cross_access_policy.arn
}

#Instance Profile
resource "aws_iam_instance_profile" "test_profile" {
  name = "test-ssm-ec2"
  role = aws_iam_role.test_role.id
}

#Attach Policies to Instance Role
resource "aws_iam_policy_attachment" "test_attach1" {
  name  = "test-attachment"
  roles = [
    aws_iam_role.test_role.id
  ]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "test_attach2" {
  name  = "test-attachment2"
  roles = [
    aws_iam_role.test_role.id
  ]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

#EC2 Instance
data "aws_ami" "amazon-linux-2" {
  most_recent = true


  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  owners = ["amazon"]
}

data "template_file" "userdata" {
  template = file("${path.module}/install-ssm.sh")
  vars     = {
    storage_bucket_access_role = var.storage_bucket_access_role
  }
}


resource "aws_instance" "test-ec2" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [
    aws_security_group.allow_tls.id
  ]
  monitoring           = "true"
  iam_instance_profile = aws_iam_instance_profile.test_profile.id
  user_data            = data.template_file.userdata.rendered
  tags                 = {
    Name        = "test-ec2"
    Owner       = "Terraform"
    environment = var.env
  }
}
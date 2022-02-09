output "ec2-instance" {
  description = "The EC2 instance"
  value       = "${aws_instance.test-ec2.id}"
}

output "ec2-instance-Profile" {
  description = "The EC2 Instance Profile"
  value       = "${aws_iam_instance_profile.test_profile.id}"
}

output "security_group_id" {
  value = "${aws_security_group.allow_tls.id}"
}
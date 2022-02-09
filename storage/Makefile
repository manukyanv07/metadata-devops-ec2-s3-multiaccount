SHELL := /usr/bin/env bash

# HOW TO EXECUTE

# Executing Terraform PLAN
#	$ make tf-plan env=<env>

# Executing Terraform APPLY
#   $ make tf-apply env=<env>

# Executing Terraform DESTROY
#	$ make tf-destroy env=<env>

all-test: clean tf-plan

.PHONY: clean
clean:
	rm -rf .terraform

.PHONY: tf-plan
tf-plan:
	terraform fmt && terraform init -backend-config ${env}/backend.conf -reconfigure && terraform validate && terraform plan -var-file ${env}/terraform.tfvars

.PHONY: tf-refresh
tf-refresh:
	terraform fmt && terraform refresh -backend-config ${env}/backend.conf -reconfigure && terraform validate && terraform refresh -var-file ${env}/terraform.tfvars

.PHONY: tf-apply
tf-apply:
	terraform fmt && terraform init -backend-config ${env}/backend.conf -reconfigure && terraform validate && terraform apply -var-file ${env}/terraform.tfvars -auto-approve

.PHONY: tf-destroy
tf-destroy:
	terraform init -backend-config ${env}/backend.conf -reconfigure && terraform destroy -var-file ${env}/terraform.tfvars
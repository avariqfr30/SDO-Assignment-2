#!/bin/bash

set -e # Bail on first sign of trouble

echo "Running Alpine. Inc Deployment Script.."

echo "Testing AWS credentials"
aws sts get-caller-identity

cd infra

path_to_ssh_key="alpine_sdo_key" # Also reflected in you.auto.tfvars, but with ".pub" suffix
echo "Creating SSH keypair ${path_to_ssh_key}..."
ssh-keygen -C ubuntu@alpine -f "${path_to_ssh_key}" -N ''

echo "Initialising Terraform..."
terraform init
echo "Validating Terraform configuration..."
terraform validate
echo "Running terraform apply, get ready to review and approve actions..."
terraform apply

echo "Output of instance IPs"
terraform output -raw app_public_hostname

terraform output -raw db_public_hostname

echo "Running ansible to output .json"
terraform output -json > outputs.json

db_public_hostname=$(jq -r '.db_public_hustname.value' outputs.json)

app_public_hostname=$(jq -r '.app_public_hustname.value' outputs.json)

echo "Running ansible to configure Foo DB"
cd .. # Back to root of lab
ansible-playbook ansible/db-playbook.yml -i infra/ansible-inventory.yml --private-key "infra/${path_to_ssh_key}"

echo "Running ansible to configure foo app"
ansible-playbook ansible/app-playbook.yml -e "db_public_hostname=${db_public_hostname}" -i infra/ansible-inventory.yml --private-key "infra/${path_to_ssh_key}"

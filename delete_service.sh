#!/bin/bash
set -e

cd terraform
terraform init
terraform destroy -var-file="variables.tfvars"
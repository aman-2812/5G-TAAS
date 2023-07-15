#!/bin/bash
set -e

cd terraform
terraform destroy -var-file="variables.tfvars"
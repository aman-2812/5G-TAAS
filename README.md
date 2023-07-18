# 5G-TAAS
Deployment of 5G network as Testbed As A Service

## Prerequisite

1) Ubuntu 22.04
2) Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) 
2) Configure [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) 

## Deploying 5G TAAS

1) Edit the file [variables.tfvars](terraform/variables.tfvars) (in terraform dir)
2) Run the file [deploy_service.sh](deploy_service.sh)
3) When prompted by the script type `yes` 

## Deleting the 5G TAAS Deployment

1) Run the script [delete_service.sh](delete_service.sh)
2) When prompted by the script type `yes` 
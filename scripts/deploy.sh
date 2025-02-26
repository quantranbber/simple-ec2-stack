#!/bin/sh

cd ./terraform
terraform apply -auto-approve -var-file=variable-dev.tfvars
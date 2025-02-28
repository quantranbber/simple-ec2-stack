#!/bin/sh

cd ./terraform
terraform init -backend-config="dev.tfbackend"
#!/bin/sh

ecr_repo=$1
image_name=$2
region=ap-southeast-1

docker build -t $image_name .

docker tag $image_name $ecr_repo

aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$region.amazonaws.com

docker push $ecr_repo
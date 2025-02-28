#!/bin/sh
INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names ${ASG_NAME} \
    --query "join(',', AutoScalingGroups[0].Instances[*].InstanceId)" \
    --output text)

aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --targets "Key=instanceIds,Values=${INSTANCE_IDS}" \
    --parameters commands='[
        "aws s3 sync s3://terraform-test-bucket-7634341/codes .",
        "ECR_URL=$(aws ssm get-parameter --name \"/myapp/ecr/url\" --query \"Parameter.Value\" --output text)",
        "ECR_IMAGE=$(aws ssm get-parameter --name \"/myapp/ecr/image\" --query \"Parameter.Value\" --output text)",
        "DB_HOST=$(aws ssm get-parameter --name \"/myapp/db/DB_HOST\" --query \"Parameter.Value\" --output text)",
        "DB_NAME=$(aws ssm get-parameter --name \"/myapp/db/DB_NAME\" --query \"Parameter.Value\" --output text)",
        "DB_USER=$(aws ssm get-parameter --name \"/myapp/db/DB_USER\" --query \"Parameter.Value\" --output text)",
        "DB_PASSWORD=$(aws ssm get-parameter --with-decryption --name \"/myapp/db/DB_PASSWORD\" --query \"Parameter.Value\" --output text)",
        "sed -i \"s#^REGION=[^$]*#REGION=${REGION}#\" .env.example",
        "sed -i \"s#^ECR_URL=[^$]*#ECR_URL=${ECR_URL}#\" .env.example",
        "sed -i \"s/^ECR_IMAGE=[^$]*/ECR_IMAGE=${ECR_IMAGE}/\" .env.example",
        "sed -i \"s/^DB_HOST=[^$]*/DB_HOST=${DB_HOST}/\" .env.example",
        "sed -i \"s/^DB_NAME=[^$]*/DB_NAME=${DB_NAME}/\" .env.example",
        "sed -i \"s/^DB_USER=[^$]*/DB_USER=${DB_USER}/\" .env.example",
        "sed -i \"s/^DB_PASSWORD=[^$]*/DB_PASSWORD=${DB_PASSWORD}/\" .env.example",
        "cp .env.example .env",
        "aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin $ECR_URL",
        "docker pull $ECR_URL/$ECR_IMAGE",
        "docker compose up -d"
    ]' \
    --region ${REGION}

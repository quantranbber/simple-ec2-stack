#!/bin/sh

while true; do
    RESPONSE=$(curl -s http://${ALB_DNS}/health)
    if [ $? -eq 0 ] && echo "$RESPONSE" | grep -q "OK"; then
        INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
            --auto-scaling-group-names ${ASG_NAME} \
            --query "join(',', AutoScalingGroups[0].Instances[*].InstanceId)" \
            --output text)

        aws ssm send-command \
            --document-name "AWS-RunShellScript" \
            --targets "Key=instanceIds,Values=${INSTANCE_IDS}" \
            --parameters commands='[
                "cd codes",
                "S3_BUCKET=$(aws ssm get-parameter --name \"/myapp/s3/bucket\" --query \"Parameter.Value\" --output text)",
                "aws s3 sync s3://$S3_BUCKET/codes .",
                "ECR_URL=$(aws ssm get-parameter --name \"/myapp/ecr/url\" --query \"Parameter.Value\" --output text)",
                "ECR_IMAGE=$(aws ssm get-parameter --name \"/myapp/ecr/image\" --query \"Parameter.Value\" --output text)",
                "DB_HOST=$(aws ssm get-parameter --name \"/myapp/db/DB_HOST\" --query \"Parameter.Value\" --output text)",
                "DB_NAME=$(aws ssm get-parameter --name \"/myapp/db/DB_NAME\" --query \"Parameter.Value\" --output text)",
                "DB_USER=$(aws ssm get-parameter --name \"/myapp/db/DB_USER\" --query \"Parameter.Value\" --output text)",
                "DB_PASSWORD=$(aws ssm get-parameter --with-decryption --name \"/myapp/db/DB_PASSWORD\" --query \"Parameter.Value\" --output text)",
                "sed -i \"s#^REGION=[^$]*#REGION=${REGION}#\" .env.example",
                "sed -i \"s#^ECR_URL=[^$]*#ECR_URL=${ECR_URL}#\" .env.example",
                "sed -i \"s/^ECR_IMAGE=[^$]*/ECR_IMAGE=${ECR_IMAGE}/\" .env.example",
                "sed -i \"s/^S3_BUCKET=[^$]*/S3_BUCKET=${S3_BUCKET}/\" .env.example",
                "sed -i \"s/^DB_HOST=[^$]*/DB_HOST=${DB_HOST}/\" .env.example",
                "sed -i \"s/^DB_NAME=[^$]*/DB_NAME=${DB_NAME}/\" .env.example",
                "sed -i \"s/^DB_USER=[^$]*/DB_USER=${DB_USER}/\" .env.example",
                "sed -i \"s/^DB_PASSWORD=[^$]*/DB_PASSWORD=${DB_PASSWORD}/\" .env.example",
                "cat .env.example",
                "cp .env.example .env",
                "aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin $ECR_URL",
                "docker pull $ECR_URL/$ECR_IMAGE",
                "docker rm -f myprj-be",
                "docker compose up -d"
            ]' \
            --region ${REGION}
        break
    else
        echo "Waiting for OK from http://${ALB_DNS}/health... (curl status: $?)"
        sleep 5
    fi
done

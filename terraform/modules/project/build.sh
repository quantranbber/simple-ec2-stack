#!/bin/sh
INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names ${ASG_NAME} \
    --query "join(',', AutoScalingGroups[0].Instances[*].InstanceId)" \
    --output text) \

aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --targets "Key=instanceIds,Values=${INSTANCE_IDS}" \
    --parameters commands='[
        "ECR_URL=$(aws ssm get-parameter --name \"/myapp/ecr/url\" --query \"Parameter.Value\" --output text)",
        "ECR_IMAGE=$(aws ssm get-parameter --name \"/myapp/ecr/image\" --query \"Parameter.Value\" --output text)",
        "DB_HOST=$(aws ssm get-parameter --name \"/myapp/db/DB_HOST\" --query \"Parameter.Value\" --output text)",
        "DB_NAME=$(aws ssm get-parameter --name \"/myapp/db/DB_NAME\" --query \"Parameter.Value\" --output text)",
        "DB_USER=$(aws ssm get-parameter --name \"/myapp/db/DB_USER\" --query \"Parameter.Value\" --output text)",
        "DB_PASSWORD=$(aws ssm get-parameter --with-decryption --name \"/myapp/db/DB_PASSWORD\" --query \"Parameter.Value\" --output text)",
        "aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin $ECR_URL",
        "docker pull $ECR_URL/$ECR_IMAGE",
        "docker run -d -p 3000:3000 \
            --name=myprj \
            --log-driver=awslogs \
            --log-opt awslogs-region=${REGION} \
            --log-opt awslogs-group=myprjLogGroup \
            --log-opt awslogs-create-group=true \
            -e DB_HOST=$DB_HOST \
            -e DB_NAME=$DB_NAME \
            -e DB_USER=$DB_USER \
            -e DB_PASSWORD=$DB_PASSWORD \
            $ECR_URL/$ECR_IMAGE"
    ]' \
    --region ${REGION}
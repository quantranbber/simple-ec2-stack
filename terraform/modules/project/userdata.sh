#!/bin/bash
apt update -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 20
node -v

###### install aws cli
apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

###### start ssm agent
snap start amazon-ssm-agent

###### install cloudwatch agent
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

###### install docker engine
apt-get update
apt-get install -y cloud-utils apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce
usermod -aG docker ubuntu

##### pull ecr image and run
# set env
aws s3 sync s3://terraform-test-bucket-7634341/codes .
REGION=ap-southeast-1
ECR_URL=$(aws ssm get-parameter --name "/myapp/ecr/url" --query "Parameter.Value" --output text)
ECR_IMAGE=$(aws ssm get-parameter --name "/myapp/ecr/image" --query "Parameter.Value" --output text)
DB_HOST=$(aws ssm get-parameter --name "/myapp/db/DB_HOST" --query "Parameter.Value" --output text)
DB_NAME=$(aws ssm get-parameter --name "/myapp/db/DB_NAME" --query "Parameter.Value" --output text)
DB_USER=$(aws ssm get-parameter --name "/myapp/db/DB_USER" --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --with-decryption --name "/myapp/db/DB_PASSWORD" --query "Parameter.Value" --output text)

sed -i "s/^REGION=[^$]*/REGION=${REGION}/" .env.example
sed -i "s#^ECR_URL=[^$]*#ECR_URL=${ECR_URL}#" .env.example
sed -i "s/^ECR_IMAGE=[^$]*/ECR_IMAGE=${ECR_IMAGE}/" .env.example
sed -i "s/^DB_HOST=[^$]*/DB_HOST=${DB_HOST}/" .env.example
sed -i "s/^DB_NAME=[^$]*/DB_NAME=${DB_NAME}/" .env.example
sed -i "s/^DB_USER=[^$]*/DB_USER=${DB_USER}/" .env.example
sed -i "s/^DB_PASSWORD=[^$]*/DB_PASSWORD=${DB_PASSWORD}/" .env.example

cp .env.example .env

# run docker container
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin $ECR_URL
docker pull $ECR_URL/$ECR_IMAGE
docker compose up -d
#!/bin/bash
apt update -y

LOG_FILE="/var/log/user-data.log"
echo "Starting user data at $(date)" > $LOG_FILE 2>&1


curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 20
node -v
echo "1. nodejs runtime install successful" >> $LOG_FILE 2>&1

###### install aws cli
apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
echo "2. aws cli install successful" >> $LOG_FILE 2>&1

###### start ssm agent
snap start amazon-ssm-agent

###### install cloudwatch agent
# wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
# dpkg -i -E ./amazon-cloudwatch-agent.deb

###### install docker engine
apt-get install -y cloud-utils apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce
usermod -aG docker ubuntu
echo "3. docker engine install successful" >> $LOG_FILE 2>&1

##### pull ecr image and run
# set env
S3_BUCKET=terraform-test-bucket-7634341
mkdir codes
cd codes
echo "4. cd to codes" >> $LOG_FILE 2>&1
aws s3 sync s3://$S3_BUCKET/codes .
echo "4. sync success?" >> $LOG_FILE 2>&1
REGION=ap-southeast-1
ECR_URL=$(aws ssm get-parameter --name "/myapp/ecr/url" --query "Parameter.Value" --output text)
ECR_IMAGE=$(aws ssm get-parameter --name "/myapp/ecr/image" --query "Parameter.Value" --output text)
DB_HOST=$(aws ssm get-parameter --name "/myapp/db/DB_HOST" --query "Parameter.Value" --output text)
DB_NAME=$(aws ssm get-parameter --name "/myapp/db/DB_NAME" --query "Parameter.Value" --output text)
DB_USER=$(aws ssm get-parameter --name "/myapp/db/DB_USER" --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --with-decryption --name "/myapp/db/DB_PASSWORD" --query "Parameter.Value" --output text)
echo "4. get env success" >> $LOG_FILE 2>&1

sed -i "s/^REGION=[^$]*/REGION=${REGION}/" .env.example
sed -i "s#^ECR_URL=[^$]*#ECR_URL=${ECR_URL}#" .env.example
sed -i "s/^ECR_IMAGE=[^$]*/ECR_IMAGE=${ECR_IMAGE}/" .env.example
sed -i "s/^S3_BUCKET=[^$]*/S3_BUCKET=${S3_BUCKET}/" .env.example
sed -i "s/^DB_HOST=[^$]*/DB_HOST=${DB_HOST}/" .env.example
sed -i "s/^DB_NAME=[^$]*/DB_NAME=${DB_NAME}/" .env.example
sed -i "s/^DB_USER=[^$]*/DB_USER=${DB_USER}/" .env.example
sed -i "s/^DB_PASSWORD=[^$]*/DB_PASSWORD=${DB_PASSWORD}/" .env.example

cp .env.example .env
echo "5. set env success" >> $LOG_FILE 2>&1

# run docker container
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin $ECR_URL
docker pull $ECR_URL/$ECR_IMAGE >> $LOG_FILE 2>&1
docker compose up -d
echo "6. run docker success" >> $LOG_FILE 2>&1

# trigger asg to continue
echo "Checking container readiness..."
MAX_ATTEMPTS=100
ATTEMPT=1
while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
  if curl -s http://localhost:3000/health | grep -q "OK"; then
    echo "Container is ready after $ATTEMPT attempts at $(date)"
    break
  else
    echo "Attempt $ATTEMPT/$MAX_ATTEMPTS: Waiting for container..."
    docker ps -a
    sleep 2
  fi
  ATTEMPT=$((ATTEMPT + 1))
done

if [ $ATTEMPT -gt $MAX_ATTEMPTS ]; then
  echo "Container failed to start after $MAX_ATTEMPTS attempts at $(date)"
  docker logs $(docker ps -q)
  exit 1
fi

echo "Fetching instance ID..."
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
if [ $? -ne 0 ]; then
  echo "Failed to get IMDSv2 token, falling back to IMDSv1..."
  INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
else
  INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
fi

if [ -z "$INSTANCE_ID" ]; then
  echo "Failed to retrieve instance ID"
  exit 1
fi

# send signal to asg
echo "Sending lifecycle action signal for instance $INSTANCE_ID..."
aws autoscaling complete-lifecycle-action \
  --lifecycle-hook-name "myprj-asg-hook" \
  --auto-scaling-group-name "my_tf_asg" \
  --lifecycle-action-result "CONTINUE" \
  --instance-id "$INSTANCE_ID"

echo "User data completed at $(date)"
#!/bin/bash

echo "Fetching environment variables from AWS SSM..."

aws ssm get-parameters-by-path --path "/myapp/" --with-decryption --query "Parameters[*].[Name,Value]" --output text | while read name value; do
    env_var=$(basename "$name")
    echo "$env_var=\"$value\"" >> .env
done

echo ".env file created successfully!"

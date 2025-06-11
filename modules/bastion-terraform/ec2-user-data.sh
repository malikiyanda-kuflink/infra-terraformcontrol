#!/bin/bash

# Install AWS CLI and jq (optional for debugging)
yum install -y aws-cli jq

# Create .ssh folder if not exists
mkdir -p /home/ec2-user/.ssh
chown ec2-user:ec2-user /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh

# Retrieve staging.pem from SSM Parameter Store
aws ssm get-parameter \
    --name "/kuflink/ssh/staging_pem" \
    --with-decryption \
    --region eu-west-2 \
    --query Parameter.Value \
    --output text > /home/ec2-user/.ssh/staging.pem

# Set correct permissions on the PEM file
chown ec2-user:ec2-user /home/ec2-user/.ssh/staging.pem
chmod 400 /home/ec2-user/.ssh/staging.pem

# OPTIONAL: log success
echo "Fetched staging.pem from SSM at $(date)" >> /home/ec2-user/fetch-ssh-key.log

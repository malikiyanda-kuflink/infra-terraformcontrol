#!/bin/bash

set -e

echo "🚀 Applying networking layer..."
cd environments/staging/networking
terraform init -upgrade
terraform apply -auto-approve
cd ../../..

echo "🚀 Applying IAM layer..."
cd environments/staging/iam
terraform init -upgrade
terraform apply -auto-approve
cd ../../..

echo "🚀 Applying shared layer..."
cd environments/staging/shared
terraform init -upgrade
terraform apply -auto-approve
cd ../../..

echo "🚀 Applying compute layer..."
cd environments/staging/compute
terraform init -upgrade
terraform apply -auto-approve
cd ../../..

echo "🚀 Applying database layer..."
cd environments/staging/database
terraform init -upgrade
terraform apply -auto-approve
cd ../../..

echo "🚀 Applying backup layer..."
cd environments/staging/backup
terraform init -upgrade
terraform apply -auto-approve
cd ../../..

echo "✅ All layers built successfully."

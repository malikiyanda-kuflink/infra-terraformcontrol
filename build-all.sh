#!/bin/bash

set -e

echo "🚀 Applying networking layer..."
cd environments/staging/networking
terraform init
terraform apply -auto-approve
cd ../../..

echo "🚀 Applying IAM layer..."
cd environments/staging/iam
terraform init
terraform apply -auto-approve
cd ../../..

echo "🚀 Applying compute layer..."
cd environments/staging/compute
terraform init
terraform apply -auto-approve
cd ../../..

echo "🚀 Applying database layer..."
cd environments/staging/database
terraform init
terraform apply -auto-approve
cd ../../..

echo "🚀 Applying backup layer..."
cd environments/staging/backup
terraform init
terraform apply -auto-approve
cd ../../..

echo "✅ All layers built."

#!/bin/bash

set -e

echo "⚠️  WARNING - this will destroy ALL staging infrastructure!"
read -p "Are you sure? Type 'yes': " confirm

if [[ "$confirm" != "yes" ]]; then
  echo "Aborting."
  exit 1
fi

echo "🚀 Destroying backup layer..."
cd environments/staging/backup
terraform destroy -auto-approve
cd ../../..

echo "🚀 Destroying database layer..."
cd environments/staging/database
terraform destroy -auto-approve
cd ../../..

echo "🚀 Destroying compute layer..."
cd environments/staging/compute
terraform destroy -auto-approve
cd ../../..

echo "🚀 Destroying IAM layer..."
cd environments/staging/iam
terraform destroy -auto-approve
cd ../../..

echo "🚀 Destroying networking layer..."
cd environments/staging/networking
terraform destroy -auto-approve
cd ../../..

echo "✅ All layers destroyed."

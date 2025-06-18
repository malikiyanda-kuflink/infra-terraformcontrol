#!/bin/bash

set -e

LAYERS=("networking" "iam" "compute" "database" "backup" "shared")

echo "🔍 Validating Terraform layers in environments/staging/..."

for layer in "${LAYERS[@]}"; do
  echo ""
  echo "🔹 Validating layer: $layer"
  cd environments/staging/$layer
  terraform init -upgrade
  terraform validate
  cd ../../..
done

echo ""
echo "✅ All layers validated successfully."

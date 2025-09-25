#!/usr/bin/env bash
set -euo pipefail

# Get the absolute path to the project root (one level above this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

LAYERS=("networking" "iam" "compute" "database" "backup" "shared" "security")

echo "🔍 Validating Terraform layers in environment..."

for layer in "${LAYERS[@]}"; do
  echo ""
  echo "🔹 Validating layer: $layer"

  LAYER_PATH="$PROJECT_ROOT/environments/test/$layer"
  cd "$LAYER_PATH"

  terraform init -upgrade
  terraform validate
done

echo ""
echo "✅ All layers validated successfully."

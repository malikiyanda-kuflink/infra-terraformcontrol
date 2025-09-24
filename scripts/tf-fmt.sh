#!/usr/bin/env bash
set -euo pipefail

# Resolve the root directory relative to this script's locations
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# If an argument is passed, use it as the root; otherwise default to project root
ROOT="${1:-$PROJECT_ROOT}"

echo "🔍 Running terraform fmt recursively under $ROOT …"
terraform fmt -recursive "$ROOT"

echo "✅ terraform fmt complete!"

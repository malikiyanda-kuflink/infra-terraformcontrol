#!/bin/bash

set -e
SECONDS=0

echo "⚠️  WARNING: This will destroy ALL staging infrastructure!"
read -p "Are you sure? Type 'yes' to continue: " confirm

if [[ "$confirm" != "yes" ]]; then
  echo "Aborted."
  exit 1
fi

TOTAL_CREATED=0
TOTAL_UPDATED=0
TOTAL_DESTROYED=0

destroy_layer() {
  local LAYER_PATH=$1
  echo "🗑️ Destroying $LAYER_PATH..."

  cd "$LAYER_PATH"

  terraform init -upgrade
  terraform plan -destroy -out=tfplan -input=false

  read CREATED UPDATED DESTROYED <<< $(terraform show -json tfplan | jq '
    .resource_changes | 
    map(.change.actions) | 
    flatten | 
    reduce .[] as $a ({"create":0, "update":0, "delete":0};
      if $a == "create" then .create += 1 
      elif $a == "update" then .update += 1 
      elif $a == "delete" then .delete += 1 else . end
    ) | [.create, .update, .delete] | @sh' | tr -d "'")

  echo "🧾 $LAYER_PATH → Created: $CREATED | Updated: $UPDATED | Destroyed: $DESTROYED"

  TOTAL_CREATED=$((TOTAL_CREATED + CREATED))
  TOTAL_UPDATED=$((TOTAL_UPDATED + UPDATED))
  TOTAL_DESTROYED=$((TOTAL_DESTROYED + DESTROYED))

  terraform destroy -auto-approve tfplan
  cd - > /dev/null
}

destroy_layer environments/staging/backup
destroy_layer environments/staging/database
destroy_layer environments/staging/compute
destroy_layer environments/staging/shared
destroy_layer environments/staging/iam
destroy_layer environments/staging/networking

RUNTIME=$SECONDS
echo "================================================="
echo "✅ All layers destroyed cleanly."
echo "📊 Total Summary → Created: $TOTAL_CREATED | Updated: $TOTAL_UPDATED | Destroyed: $TOTAL_DESTROYED"
echo "⏱️ Total time taken: $(($RUNTIME / 60)) min $(($RUNTIME % 60)) sec"

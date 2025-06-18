#!/bin/bash

set -e
SECONDS=0

TOTAL_CREATED=0
TOTAL_UPDATED=0
TOTAL_DESTROYED=0

apply_layer() {
  local LAYER_PATH=$1
  echo "🚀 Applying $LAYER_PATH..."

  cd "$LAYER_PATH"

  terraform init -upgrade
  terraform plan -out=tfplan -input=false

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

  terraform apply -auto-approve tfplan
  cd - > /dev/null
}

apply_layer environments/staging/networking
apply_layer environments/staging/iam
apply_layer environments/staging/shared
apply_layer environments/staging/compute
apply_layer environments/staging/database
apply_layer environments/staging/backup

RUNTIME=$SECONDS
echo "================================================="
echo "✅ All layers built successfully."
echo "📊 Total Summary → Created: $TOTAL_CREATED | Updated: $TOTAL_UPDATED | Destroyed: $TOTAL_DESTROYED"
echo "⏱️ Total time taken: $(($RUNTIME / 60)) min $(($RUNTIME % 60)) sec"

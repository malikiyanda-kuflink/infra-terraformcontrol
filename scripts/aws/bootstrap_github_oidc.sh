#!/usr/bin/env bash
# Robust, idempotent bootstrap for GitHub OIDC + Terraform backend + per-layer inline policies.
# Never hard-fails: records any errors and prints them in the summary.
set -euo pipefail

########################
# --- CONFIG BLOCK --- #
########################
AWS_REGION="eu-west-2"
ACCOUNT_ID="137167813802"

# --- CONFIG BLOCK ---
REPOS=("malikiyanda-kuflink/infra-terraformcontrol" "kuflink/infra-terraformcontrol")
BRANCH="test-git"


ROLE_NAME="kuflink-test-github-oidc-terraform"
STATE_BUCKET="kuflink-test-states"
LOCK_TABLE="kuflink-tf-locks-test"

# Toggle these if you want the script to also ensure backend infra exists
ENSURE_STATE_BACKEND=1   # 1=create-if-missing S3/DDB, 0=skip

#################################
# --- INTERNAL / DO NOT EDIT ---#
#################################
OIDC_URL="https://token.actions.githubusercontent.com"
OIDC_THUMBPRINT="6938fd4d98bab03faadb97b34396831e3780aea1"

CREATED_OIDC=0
CREATED_ROLE=0
UPDATED_TRUST=0
CREATED_BUCKET=0
CREATED_LOCKS=0

declare -a SUMMARY
declare -a ERRORS
SUMMARY=()
ERRORS=()
HAVE_ERRORS=0

say() { echo -e "[$(date +%H:%M:%S)] $*"; }
note() { SUMMARY+=("$*"); }
err()  { HAVE_ERRORS=1; ERRORS+=("$*"); }

aws_sts() {
  if ! aws sts get-caller-identity --query Account --output text >/dev/null 2>&1; then
    err "AWS STS call failed. Are your admin/SSO credentials set for account ${ACCOUNT_ID}?"
  fi
}

normalize_url() {
  local u="$1"
  u="${u#https://}"; u="${u#http://}"
  echo "$u"
}

ensure_oidc_provider() {
  say "Checking OIDC provider for ${OIDC_URL}"
  local existing_arns url norm_url norm_target
  norm_target="$(normalize_url "$OIDC_URL")"
  existing_arns="$(aws iam list-open-id-connect-providers --query 'OpenIDConnectProviderList[].Arn' --output text 2>/dev/null || true)"

  if [[ -n "${existing_arns}" ]]; then
    for arn in ${existing_arns}; do
      url="$(aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$arn" --query 'Url' --output text 2>/dev/null || true)"
      norm_url="$(normalize_url "$url")"
      if [[ "$norm_url" == "$norm_target" ]]; then
        say "-> OIDC provider already exists: $arn"
        note "OIDC provider exists: $arn"
        return 0
      fi
    done
  fi

  say "-> Creating OIDC provider (idempotent)"
  local out rc
  out="$(aws iam create-open-id-connect-provider \
    --url "$OIDC_URL" \
    --client-id-list sts.amazonaws.com \
    --thumbprint-list "$OIDC_THUMBPRINT" 2>&1)"; rc=$?
  if (( rc == 0 )); then
    CREATED_OIDC=1
    note "OIDC provider created"
  else
    if grep -qi "EntityAlreadyExists" <<<"$out"; then
      say "-> OIDC provider exists (caught by API), continuing"
      note "OIDC provider exists (API)"
    else
      err "Create OIDC provider failed: $out"
    fi
  fi
}

write_json() {
  # $1 = filename, $2 = JSON content
  printf '%s\n' "$2" > "$1"
}

trust_policy_json() {
  # Build the StringLike->sub array for both repos
  local subs=()
  for r in "${REPOS[@]}"; do
    subs+=("repo:${r}:ref:refs/heads/*")
    subs+=("repo:${r}:pull_request")
  done

  # Join into JSON array
  local sub_json
  sub_json="$(printf '"%s",' "${subs[@]}")"
  sub_json="[${sub_json%,}]"

  cat <<JSON
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Principal":{"Federated":"arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"},
      "Action":"sts:AssumeRoleWithWebIdentity",
      "Condition":{
        "StringEquals":{
          "token.actions.githubusercontent.com:aud":"sts.amazonaws.com"
        },
        "StringLike":{
          "token.actions.githubusercontent.com:sub": ${sub_json}
        }
      }
    }
  ]
}
JSON
}


ensure_role_and_trust() {
  say "Ensuring role ${ROLE_NAME} exists with correct trust policy"
  local tp="trust-policy.json"
  write_json "$tp" "$(trust_policy_json)"

  if aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
    say "-> Role exists; updating trust policy"
    if ! aws iam update-assume-role-policy --role-name "$ROLE_NAME" --policy-document "file://$tp" >/dev/null 2>&1; then
      err "Update assume role policy failed for ${ROLE_NAME}"
    else
      UPDATED_TRUST=1
      note "Updated trust policy for ${ROLE_NAME}"
    fi
  else
    say "-> Creating role"
    if ! aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document "file://$tp" >/dev/null 2>&1; then
      err "Create role failed for ${ROLE_NAME}"
    else
      CREATED_ROLE=1
      note "Created role ${ROLE_NAME}"
    fi
  fi

  # Optional: session duration & tags (best-effort)
  aws iam update-role --role-name "$ROLE_NAME" --max-session-duration 3600 >/dev/null 2>&1 || true
  aws iam tag-role --role-name "$ROLE_NAME" \
    --tags Key=Project,Value=Kuflink Key=Environment,Value=Test >/dev/null 2>&1 || true
}

ensure_backend_infra() {
  [[ "$ENSURE_STATE_BACKEND" -eq 1 ]] || { note "State backend creation skipped"; return 0; }

  say "Checking S3 bucket: ${STATE_BUCKET}"
  if ! aws s3api head-bucket --bucket "${STATE_BUCKET}" >/dev/null 2>&1; then
    say "-> Creating bucket ${STATE_BUCKET} in ${AWS_REGION}"
    if ! aws s3api create-bucket --bucket "${STATE_BUCKET}" --region "${AWS_REGION}" \
         --create-bucket-configuration "LocationConstraint=${AWS_REGION}" >/dev/null 2>&1; then
      err "Create S3 bucket ${STATE_BUCKET} failed (may exist elsewhere or be owned by another account)"
    else
      CREATED_BUCKET=1
      note "Created S3 bucket ${STATE_BUCKET}"
    fi
    aws s3api put-bucket-versioning --bucket "${STATE_BUCKET}" \
      --versioning-configuration Status=Enabled >/dev/null 2>&1 || err "Enable versioning failed on ${STATE_BUCKET}"
    aws s3api put-bucket-encryption --bucket "${STATE_BUCKET}" \
      --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' >/dev/null 2>&1 || err "Set encryption failed on ${STATE_BUCKET}"
    aws s3api put-public-access-block --bucket "${STATE_BUCKET}" \
      --public-access-block-configuration '{"BlockPublicAcls":true,"IgnorePublicAcls":true,"BlockPublicPolicy":true,"RestrictPublicBuckets":true}' >/dev/null 2>&1 || err "Public access block failed on ${STATE_BUCKET}"
    # Optional TLS-only policy
    local bp_out
    bp_out="$(cat <<POL
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"DenyInsecureTransport",
      "Effect":"Deny",
      "Principal":"*",
      "Action":"s3:*",
      "Resource":[
        "arn:aws:s3:::${STATE_BUCKET}",
        "arn:aws:s3:::${STATE_BUCKET}/*"
      ],
      "Condition":{"Bool":{"aws:SecureTransport":"false"}}
    }
  ]
}
POL
)"
    aws s3api put-bucket-policy --bucket "${STATE_BUCKET}" --policy "${bp_out}" >/dev/null 2>&1 || err "Bucket policy TLS-only failed on ${STATE_BUCKET}"
  else
    say "-> Bucket exists"
    note "S3 bucket exists: ${STATE_BUCKET}"
  fi

  say "Checking DynamoDB table: ${LOCK_TABLE}"
  if ! aws dynamodb describe-table --table-name "${LOCK_TABLE}" >/dev/null 2>&1; then
    say "-> Creating table ${LOCK_TABLE}"
    if ! aws dynamodb create-table \
        --table-name "${LOCK_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST >/dev/null 2>&1; then
      err "Create DynamoDB table ${LOCK_TABLE} failed"
    else
      if ! aws dynamodb wait table-exists --table-name "${LOCK_TABLE}" >/dev/null 2>&1; then
        err "Wait for DynamoDB table ${LOCK_TABLE} failed"
      else
        CREATED_LOCKS=1
        note "Created DynamoDB lock table ${LOCK_TABLE}"
      fi
    fi
  else
    say "-> Lock table exists"
    note "DynamoDB table exists: ${LOCK_TABLE}"
  fi
}

policy_backend_scoped_json() {
cat <<JSON
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[ "s3:ListBucket" ],
      "Resource":"arn:aws:s3:::${STATE_BUCKET}",
      "Condition":{"StringLike":{"s3:prefix":["${BRANCH}/*"]}}
    },
    {
      "Effect":"Allow",
      "Action":[ "s3:GetObject","s3:PutObject","s3:DeleteObject" ],
      "Resource":"arn:aws:s3:::${STATE_BUCKET}/${BRANCH}/*"
    },
    {
      "Effect":"Allow",
      "Action":[ "dynamodb:DescribeTable","dynamodb:GetItem","dynamodb:PutItem","dynamodb:DeleteItem" ],
      "Resource":"arn:aws:dynamodb:${AWS_REGION}:${ACCOUNT_ID}:table/${LOCK_TABLE}"
    }
  ]
}
JSON
}

policy_foundation_json() {
cat <<'JSON'
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[
        "ec2:*Vpc*","ec2:*Subnet*","ec2:*Route*","ec2:*InternetGateway*","ec2:*NatGateway*",
        "ec2:*RouteTable*","ec2:Describe*","ec2:*VpcEndpoint*","ec2:CreateTags","ec2:DeleteTags",
        "ec2:AllocateAddress","ec2:ReleaseAddress","ec2:DescribeAddresses","ec2:AssociateAddress","ec2:DisassociateAddress"
      ],
      "Resource":"*"
    },
    {
      "Effect":"Allow",
      "Action":[
        "iam:CreateRole","iam:DeleteRole","iam:GetRole","iam:UpdateRole","iam:TagRole","iam:UntagRole",
        "iam:ListRoles","iam:ListRoleTags",
        "iam:CreatePolicy","iam:DeletePolicy","iam:GetPolicy","iam:GetPolicyVersion","iam:ListPolicyVersions",
        "iam:CreatePolicyVersion","iam:DeletePolicyVersion","iam:TagPolicy","iam:UntagPolicy","iam:ListPolicyTags",
        "iam:AttachRolePolicy","iam:DetachRolePolicy","iam:ListAttachedRolePolicies",
        "iam:PutRolePolicy","iam:DeleteRolePolicy","iam:GetRolePolicy","iam:ListRolePolicies",
        "iam:CreateInstanceProfile","iam:DeleteInstanceProfile","iam:GetInstanceProfile",
        "iam:TagInstanceProfile","iam:UntagInstanceProfile","iam:ListInstanceProfileTags",
        "iam:AddRoleToInstanceProfile","iam:RemoveRoleFromInstanceProfile",
        "iam:ListPolicies","iam:ListInstanceProfiles",
        "iam:PassRole"
      ],
      "Resource":"*"
    },
    {
      "Effect":"Allow",
      "Action":[
        "ec2:CreateTransitGateway","ec2:DeleteTransitGateway","ec2:ModifyTransitGateway","ec2:DescribeTransitGateways",
        "ec2:CreateTransitGatewayVpcAttachment","ec2:DeleteTransitGatewayVpcAttachment","ec2:ModifyTransitGatewayVpcAttachment","ec2:DescribeTransitGatewayVpcAttachments",
        "ec2:CreateTransitGatewayRouteTable","ec2:DeleteTransitGatewayRouteTable","ec2:DescribeTransitGatewayRouteTables",
        "ec2:CreateTransitGatewayRoute","ec2:DeleteTransitGatewayRoute","ec2:ReplaceTransitGatewayRoute","ec2:SearchTransitGatewayRoutes",
        "ec2:AssociateTransitGatewayRouteTable","ec2:DisassociateTransitGatewayRouteTable",
        "ec2:PropagateTransitGatewayRouteTable","ec2:DisableTransitGatewayRouteTablePropagation","ec2:EnableTransitGatewayRouteTablePropagation"
      ],
      "Resource":"*"
    },
    {
      "Effect":"Allow",
      "Action":[
        "ec2:CreateCustomerGateway","ec2:DeleteCustomerGateway","ec2:DescribeCustomerGateways",
        "ec2:CreateVpnGateway","ec2:DeleteVpnGateway","ec2:AttachVpnGateway","ec2:DetachVpnGateway","ec2:DescribeVpnGateways",
        "ec2:CreateVpnConnection","ec2:DeleteVpnConnection","ec2:ModifyVpnConnection","ec2:DescribeVpnConnections",
        "ec2:CreateVpnConnectionRoute","ec2:DeleteVpnConnectionRoute","ec2:EnableVgwRoutePropagation","ec2:DisableVgwRoutePropagation"
      ],
      "Resource":"*"
    }
  ]
}
JSON
}

policy_platform_json() {
  cat <<'JSON'
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[
        "ecr:*Repository*","ecr:Describe*","ecr:GetAuthorizationToken"
      ],
      "Resource":"*"
    },
    {
      "Effect":"Allow",
      "Action":[
        "elasticloadbalancing:*","autoscaling:*","cloudwatch:*","logs:*","events:*","ssm:Describe*","ssm:Get*","ssm:List*"
      ],
      "Resource":"*"
    },
    {
      "Effect":"Allow",
      "Action":[
        "iam:PassRole"
      ],
      "Resource":"*",
      "Condition":{
        "StringLike":{
          "iam:PassedToService":[
            "ec2.amazonaws.com","ecs.amazonaws.com","ecs-tasks.amazonaws.com","eks.amazonaws.com"
          ]
        }
      }
    },
    {
      "Effect":"Allow",
      "Action":[
        "wafv2:CreateWebACL","wafv2:UpdateWebACL","wafv2:DeleteWebACL","wafv2:GetWebACL","wafv2:ListWebACLs",
        "wafv2:AssociateWebACL","wafv2:DisassociateWebACL","wafv2:GetWebACLForResource","wafv2:ListResourcesForWebACL",
        "wafv2:CreateIPSet","wafv2:UpdateIPSet","wafv2:DeleteIPSet","wafv2:GetIPSet","wafv2:ListIPSets",
        "wafv2:CreateRegexPatternSet","wafv2:UpdateRegexPatternSet","wafv2:DeleteRegexPatternSet","wafv2:GetRegexPatternSet","wafv2:ListRegexPatternSets",
        "wafv2:CreateRuleGroup","wafv2:UpdateRuleGroup","wafv2:DeleteRuleGroup","wafv2:GetRuleGroup","wafv2:ListRuleGroups",
        "wafv2:PutLoggingConfiguration","wafv2:DeleteLoggingConfiguration","wafv2:GetLoggingConfiguration","wafv2:ListLoggingConfigurations",
        "wafv2:TagResource","wafv2:UntagResource","wafv2:ListTagsForResource",
        "wafv2:GetManagedRuleSet","wafv2:ListManagedRuleSets","wafv2:CheckCapacity"
      ],
      "Resource":"*"
    },
    {
      "Effect":"Allow",
      "Action":[
        "firehose:CreateDeliveryStream","firehose:DeleteDeliveryStream","firehose:DescribeDeliveryStream",
        "firehose:ListDeliveryStreams","firehose:PutRecord","firehose:PutRecordBatch","firehose:TagDeliveryStream","firehose:UntagDeliveryStream"
      ],
      "Resource":"*"
    },
    {
      "Effect":"Allow",
      "Action":[
        "s3:CreateBucket","s3:PutBucketPolicy","s3:PutBucketAcl","s3:PutEncryptionConfiguration",
        "s3:PutBucketPublicAccessBlock","s3:PutBucketOwnershipControls","s3:GetBucketLocation","s3:ListBucket",
        "s3:PutBucketLogging","s3:PutBucketVersioning"
      ],
      "Resource":"*"
    }
  ]
}
JSON
}

policy_data_json() {
cat <<'JSON'
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[
        "rds:*DBInstance*","rds:*DBSubnetGroup*","rds:*ParameterGroup*",
        "rds:*SecurityGroup*","rds:AddTagsToResource","rds:RemoveTagsFromResource","rds:Describe*"
      ],
      "Resource":"*"
    },
    {
      "Effect":"Allow",
      "Action":[
        "elasticache:*ReplicationGroup*","elasticache:*CacheSubnetGroup*",
        "elasticache:AddTagsToResource","elasticache:RemoveTagsFromResource","elasticache:Describe*"
      ],
      "Resource":"*"
    },
    {
      "Effect":"Allow",
      "Action":[ "kms:DescribeKey","kms:ListKeys","kms:ListAliases" ],
      "Resource":"*"
    }
  ]
}
JSON
}

policy_apps_json() {
cat <<'JSON'
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[
        "ec2:CreateSecurityGroup","ec2:AuthorizeSecurityGroup*","ec2:RevokeSecurityGroup*",
        "ec2:CreateTags","ec2:DeleteTags","ec2:Describe*"
      ],
      "Resource":"*"
    },
    { "Effect":"Allow","Action":[ "elasticloadbalancing:*" ],"Resource":"*" },
    { "Effect":"Allow","Action":[ "autoscaling:*" ],"Resource":"*" },
    { "Effect":"Allow","Action":[ "ecr:*Repository*","ecr:Describe*" ],"Resource":"*" },
    {
      "Effect":"Allow",
      "Action":[ "iam:PassRole" ],
      "Resource":"*",
      "Condition":{ "StringLike":{ "iam:PassedToService":[ "ec2.amazonaws.com","ecs-tasks.amazonaws.com" ] } }
    }
  ]
}
JSON
}

attach_inline_policies() {
  say "Attaching inline policies to ${ROLE_NAME} (overwrites if they exist)"

  local p_backend="policy-backend.json"
  local p_foundation="policy-foundation.json"
  local p_platform="policy-platform.json"
  local p_data="policy-data.json"
  local p_apps="policy-apps.json"

  write_json "$p_backend"    "$(policy_backend_scoped_json)"
  write_json "$p_foundation" "$(policy_foundation_json)"
  write_json "$p_platform"   "$(policy_platform_json)"
  write_json "$p_data"       "$(policy_data_json)"
  write_json "$p_apps"       "$(policy_apps_json)"

  aws iam put-role-policy --role-name "$ROLE_NAME" --policy-name "test-tf-backend-access" --policy-document "file://$p_backend" >/dev/null 2>&1 || err "Attach inline policy test-tf-backend-access failed"
  aws iam put-role-policy --role-name "$ROLE_NAME" --policy-name "tf-foundation"        --policy-document "file://$p_foundation" >/dev/null 2>&1 || err "Attach inline policy tf-foundation failed"
  aws iam put-role-policy --role-name "$ROLE_NAME" --policy-name "tf-platform"          --policy-document "file://$p_platform" >/dev/null 2>&1 || err "Attach inline policy tf-platform failed"
  aws iam put-role-policy --role-name "$ROLE_NAME" --policy-name "tf-data"              --policy-document "file://$p_data" >/dev/null 2>&1 || err "Attach inline policy tf-data failed"
  aws iam put-role-policy --role-name "$ROLE_NAME" --policy-name "tf-apps"              --policy-document "file://$p_apps" >/dev/null 2>&1 || err "Attach inline policy tf-apps failed"

  # log attached (best-effort)
  note "Attached policy test-tf-backend-access"
  note "Attached policy tf-foundation"
  note "Attached policy tf-platform"
  note "Attached policy tf-data"
  note "Attached policy tf-apps"
}

########################
# --- MAIN EXECUTION --#
########################
say "Verifying AWS session for account ${ACCOUNT_ID} in ${AWS_REGION}"
aws configure set region "${AWS_REGION}"
aws_sts

ensure_oidc_provider
ensure_role_and_trust
ensure_backend_infra
attach_inline_policies

ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

echo
echo "========= BOOTSTRAP SUMMARY ========="
echo "Account:            ${ACCOUNT_ID}"
echo "Region:             ${AWS_REGION}"
echo "Assumable role ARN: ${ROLE_ARN}"
echo "OIDC provider:      $([[ $CREATED_OIDC -eq 1 ]] && echo 'created' || echo 'exists')"
echo "Role:               $([[ $CREATED_ROLE -eq 1 ]] && echo 'created' || echo 'exists')"
echo "Trust policy:       $([[ $UPDATED_TRUST -eq 1 ]] && echo 'updated' || echo 'set/unchanged')"
if [[ "$ENSURE_STATE_BACKEND" -eq 1 ]]; then
  echo "State bucket:       ${STATE_BUCKET} $([[ $CREATED_BUCKET -eq 1 ]] && echo '(created)' || echo '(exists or not changed)')"
  echo "Lock table:         ${LOCK_TABLE} $([[ $CREATED_LOCKS -eq 1 ]] && echo '(created)' || echo '(exists)')"
else
  echo "State backend:      skipped (ENSURE_STATE_BACKEND=0)"
fi
echo "---- Actions summary ----"
if [ "${#SUMMARY[@]}" -gt 0 ]; then
  for s in "${SUMMARY[@]}"; do echo "- $s"; done
else
  echo "- No actions recorded"
fi
if [ "$HAVE_ERRORS" -eq 1 ]; then
  echo "---- Non-fatal errors ----"
  for e in "${ERRORS[@]}"; do echo "- $e"; done
else
  echo "---- Non-fatal errors ----"
  echo "- None"
fi
echo "All steps completed (fatal errors prevented)."

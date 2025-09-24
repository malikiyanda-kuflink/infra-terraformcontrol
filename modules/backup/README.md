# Backup Terraform Module

Provides:

✅ Backup Vault  
✅ Vault Lock (protection from accidental/ransomware deletion)  
✅ Backup Plan with:
- Daily → 35 days
- Weekly → 12 weeks
- Monthly → 12 months
- Yearly → 7 years

✅ Backup Selection:
- RDS instance
- EC2 instance

IAM role required → must be passed in.

Usage → Reference this module from `environments/test/backup/main.tf`.

---

## Notes

Vault Lock:

→ Provides protection from accidentally deleting backups → Vault becomes immutable after `changeable_for_days` period.

Plan Rules:

→ Each rule has its own CRON schedule → no overlap.

Resources:

→ Any new RDS / EC2 instance can be added by adding their ARN to `resources`.

---

## KMS / DR Consideration

→ By default, no `kms_key_arn` is set → AWS Backup Vault uses **AWS-managed KMS key** (`alias/aws/backup`).  
→ This ensures **safe Disaster Recovery** — backups can be restored even if customer-managed KMS keys are missing or not available.

→ If you choose to add a `kms_key_arn` (customer-managed KMS key), you must:
- Manage the KMS key fully via Terraform.
- Ensure the KMS key is **recreated first** in any DR recovery scenario.
- If doing cross-account/cross-region restores → configure correct key policies and permissions.

→ Failure to restore or pre-create the KMS key in DR can render backups **unrestorable**.

---


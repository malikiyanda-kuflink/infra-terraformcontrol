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

Usage → Reference this module from `environments/staging/backup/main.tf`.

---

## Notes

Vault Lock:

→ Provides protection from accidentally deleting backups → Vault becomes immutable after `changeable_for_days` period.

Plan Rules:

→ Each rule has its own CRON schedule → no overlap.

Resources:

→ Any new RDS / EC2 instance can be added by adding their ARN to `resources`.


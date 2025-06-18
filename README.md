# Kuflink Infrastructure Terraform Control Repo

This repository manages the **Infrastructure as Code (IaC)** for the Kuflink AWS environment(s), using Terraform.

It is structured to follow a **modular, layered Terraform architecture** for easy management and scaling.

---

## 📁 Repo Structure

```txt
infra-terraformcontrol/
├── modules/                         # Reusable Terraform modules (shared across envs)
│   ├── backup/                      # AWS Backup vaults + plans + rules
│   ├── ec2-bastion/                 # Bastion EC2 + SG + EIP + IAM role
│   ├── ec2-test/                    # EC2 test instance provisioning
│   ├── elastic-cache-redis/        # ElastiCache Redis cluster + subnet groups
│   ├── iam/                         # IAM roles and policies
│   ├── parameter-store/            # SSM Parameter Store secrets/keys
│   ├── rds/                         # RDS instance creation module
│   ├── rds-restored/               # RDS restore-from-snapshot module
│   ├── vpc/                         # VPC + Subnets + IGW + NAT + Route Tables
│   └── web-app/                     # Web application EC2/Beanstalk config
├── environments/
│   └── staging/
│       ├── networking/              # VPC + Subnets layer
│       ├── iam/                     # IAM roles layer
│       ├── compute/                 # EC2 + Bastion hosts
│       ├── database/                # RDS + restore logic
│       ├── backup/                  # AWS Backup plan + vault
│       └── shared/                  # ACM, S3, Route53 records for staging
├── build-all.sh                     # Script to build all layers
├── destroy-all.sh                   # Script to destroy all layers in order
├── run_terraform_fmt.sh             # Formats all Terraform code
├── validate-all.sh                  # Validates all Terraform layers
└── README.md                        # This file
✅ Build & Destroy Order
🔨 Build Order
Apply layers in this order:

1️⃣ Networking → VPC + subnets
2️⃣ IAM → roles needed by EC2, RDS, Backup
3️⃣ Compute → EC2s, Bastion hosts
4️⃣ Database → RDS or Restored instance
5️⃣ Backup → Plan, vaults, rules (needs EC2/RDS ARNs)

Why this order?

Backup must be applied after EC2 and RDS so it can target them.

IAM must come before EC2, RDS, and Backup to provide necessary roles and policies.

💣 Destroy Order
Destroy layers in this order:

1️⃣ Backup → Detach from EC2/RDS first
2️⃣ Database → Deletes RDS instance
3️⃣ Compute → EC2s, Bastion
4️⃣ IAM → Remove only after EC2 + Backup
5️⃣ Networking → Last, since all layers depend on VPC

Why this order?

AWS Backup holds references that block RDS/EC2 deletion unless removed first.

IAM roles might be attached to still-running EC2/RDS if destroyed early.

Networking cannot be removed while anything depends on it.

📌 Notes
Each layer is isolated and applied independently:

terraform init
terraform apply
terraform destroy
Remote state is stored in S3 with DynamoDB locking per environment and layer.

Tags are consistently applied for cost tracking and traceability.

🌐 DNS CNAME for DB Connectivity
To enable seamless cutovers between DB instances (e.g. during migrations or failovers), we use a Route 53 CNAME record like:


db.staging.brickfin.co.uk → kuflink-prod.xxxxxx.rds.amazonaws.com
🔧 How It Works
Applications connect using the CNAME (db.staging.brickfin.co.uk), not the actual RDS hostname.

Behind the scenes, the CNAME points to the active RDS instance.

During a restore or blue/green deployment, you only update the DNS record — apps don’t need to change.

✅ Benefits
✅ No app config changes during DB migration or failover

⚡ Fast switchovers — just update the CNAME value

🔄 Rollback-friendly — repoint to the previous instance if needed

💙 Enables Blue/Green DB flows or snapshot restore without downtime

⏱️ TTL = 60s allows DNS changes to propagate quickly

📌 Action Required (Pre-Migration)
 Create CNAME in Route 53

 Ensure all app environments (Elastic Beanstalk, EC2, etc) use this CNAME for DB connections

 Verify connectivity from within VPC (especially if using private subnets)
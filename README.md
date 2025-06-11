# Kuflink Infrastructure Terraform Control Repo

This repository manages the **Infrastructure as Code (IaC)** for the Kuflink AWS environment(s), using Terraform.

It is structured to follow a **modular, layered Terraform architecture** for easy management and scaling.

---

## 📁 Repo Structure

```txt
infra-terraformcontrol/
├── modules/                      # Reusable Terraform modules (shared across envs)
│   ├── vpc-terraform/             # VPC + Subnets + IGW + NAT + RTs
│   ├── bastion-terraform/         # Bastion EC2 + SG + EIP + IAM role
│   ├── rds-terraform/             # RDS instance/cluster
│   ├── ecs-cluster-terraform/     # ECS Cluster, Services, ALB
│   ├── iam-terraform/             # IAM roles and policies
│   ├── s3-bucket-terraform/       # S3 buckets and policies
│   ├── acm-terraform/             # ACM certs for ALB/CloudFront
│   ├── route53-terraform/         # Route53 Hosted Zones and Records
│   ├── backup-terraform/          # AWS Backup vaults + plans + rules
├── environments/                  
│   ├── staging/                   # Staging environment
│   │   ├── networking/            # VPC + Subnets layer
│   │   ├── iam/                   # IAM roles layer
│   │   ├── compute/               # Bastion + EC2 layer
│   │   ├── database/              # RDS layer
│   │   ├── backup/                # AWS Backup layer
│   │   ├── shared/                # ACM, S3, Route53 for staging account
└── README.md                      # This file


Build & Destroy Order
✅ Build Order
→ You should apply layers in this order:

1️⃣ Networking → provides VPC and subnets
2️⃣ IAM → creates roles needed by EC2, Backup, etc
3️⃣ Compute → EC2 instances, Bastion
4️⃣ Database → RDS instance
5️⃣ Backup → AWS Backup Vault + Plan + Rules (needs EC2 + RDS ARNs)

Reason: Backup must be applied after Database + Compute so it can attach to those resources.

✅ Destroy Order
→ You must destroy layers in this order:

1️⃣ Backup → first, so it detaches from RDS/EC2 cleanly
2️⃣ Database → RDS instance
3️⃣ Compute → EC2 instances, Bastion
4️⃣ IAM → roles after Compute & Backup have been removed
5️⃣ Networking → last, so VPC is not in use by anything

Reason:

Backup layer must be destroyed first → otherwise AWS Backup will hold references to RDS/EC2 resources.

IAM must be destroyed after EC2 and Backup so roles are not in use.

Networking is destroyed last because everything depends on the VPC.

Notes
Each layer is applied and managed separately → terraform init, terraform apply, terraform destroy per layer.

Remote state is used (S3 + DynamoDB locking) to safely manage state per layer.

Tags are consistent across layers for traceability.
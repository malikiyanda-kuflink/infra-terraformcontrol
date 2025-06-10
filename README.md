# Kuflink Infrastructure Terraform Control Repo

This repository manages the **Infrastructure as Code (IaC)** for the Kuflink AWS environment(s), using Terraform.

It is structured to be modular, layered Terraform architecture.

---

## 📁 Repo Structure

```txt
infra-terraformcontrol/
├── modules/                      # Reusable Terraform modules (shared across envs)
│   ├── vpc-terraform/             # VPC + Subnets + IGW + NAT + RTs
│   ├── bastion-terraform/         # Bastion EC2 + SG + EIP + IAM role
│   ├── rds-terraform/             # RDS instance/cluster
│   ├── ecs-cluster-terraform/     # ECS Cluster, Services, ALB
│   ├── iam-roles-terraform/       # IAM roles and policies
│   ├── s3-bucket-terraform/       # S3 buckets and policies
│   ├── acm-terraform/             # ACM certs for ALB/CloudFront
│   ├── route53-terraform/         # Route53 Hosted Zones and Records
├── environments/                  
│   ├── staging/                   # Staging environment
│   │   ├── networking/            # VPC + Subnets layer
│   │   ├── compute/               # Bastion + EC2 layer
│   │   ├── database/              # RDS layer
│   │   ├── shared/                # ACM, S3, Route53 for staging account
└── README.md                      # This file

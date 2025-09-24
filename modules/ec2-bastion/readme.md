# EC2-Bastion Module Documentation

## Overview

The bastion module creates environment-specific bastion host infrastructure for secure access to private resources. This module provides different functionality based on deployment environment: MySQL proxy forwarding for staging/test environments and standard SSH bastion capabilities for production environments.

## Architecture

### High-Level Component Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      Staging Environment                        │
│                                                                 │
│ External Client ──TCP:9990──▶ Bastion EIP ──socat──▶ RDS:3306  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Production Environment                       │
│                                                                 │
│ Admin Users ──SSH:22──▶ Bastion EIP ──tunnel──▶ Internal VPC   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Environment-Specific Behavior

#### Staging/Test: MySQL Proxy Bastion
- **socat TCP forwarding** from port 9990 to MySQL port 3306
- **DNS proxy records** for external client access
- **Loop protection** prevents self-targeting
- **SystemD service management** for reliability

#### Production: Standard SSH Bastion  
- **Standard SSH access** on port 22
- **Basic system utilities** and monitoring
- **SSM Agent integration** for AWS Systems Manager
- **Minimal attack surface** with no network forwarding

## Module Structure

```
# Test/Staging Project
test-project/
├── main.tf              # Test environment infrastructure
├── variables.tf         # Input variables
├── user-data/
│   └── bastion_user_data.sh  # MySQL proxy with socat configuration
└── ...

# Production Project  
production-project/
├── main.tf              # Production environment infrastructure
├── variables.tf         # Input variables
├── user-data/
│   └── bastion_user_data.sh  # Basic Ubuntu setup with SSM
└── ...

# Shared Module (referenced by both projects)
ec2-bastion/
├── main.tf              # Core EC2 and networking resources
├── variables.tf         # Input variables
├── outputs.tf          # Output values
└── README.md           # This documentation
```

## Core Resources Created

### 1. EC2 Instance (`aws_instance.bastion_host`)
- **Amazon Linux 2** (staging) or **Ubuntu LTS** (production)
- **Instance profile** attached for SSM parameter access
- **IMDSv2 enabled** with instance metadata tags support
- **Public subnet placement** for internet accessibility
- **Security group attachment** for access control

### 2. Elastic IP (`aws_eip.bastion_eip`)
- **Static public IP** for consistent external access
- **VPC domain** allocation for VPC resources
- **Named resource** for easy identification
- **Cost-effective** static IP solution

### 3. EIP Association (`aws_eip_association.bastion_eip_assoc`)
- **Links Elastic IP** to bastion instance
- **Ensures consistent** public IP across reboots
- **Immediate association** upon instance creation

### 4. User Data Scripts (Environment-Specific)

#### Test/Staging User Data (`bastion_user_data.sh`)
- **socat installation** and systemd service configuration
- **MySQL forwarding** from port 9990 to target RDS endpoint  
- **SSH key management** via SSM parameters
- **DNS resolution checks** and loop protection
- **Service health monitoring** and automatic restart
- **Amazon Linux 2** package management (yum)

#### Production User Data (`bastion_user_data.sh`)
- **Basic Ubuntu setup** with system updates
- **SSM Agent installation** and configuration
- **Standard utilities** (htop, jq, curl, net-tools)
- **Log directory setup** for application logging
- **Minimal configuration** for security
- **Ubuntu package management** (apt-get)

## Variables

### Required Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `public_subnet_id` | `string` | Public subnet ID for bastion placement | `"subnet-12345678"` |
| `vpc_id` | `string` | VPC ID where bastion will be deployed | `"vpc-12345678"` |
| `ssh_key_parameter_name` | `string` | SSM parameter name for SSH public keys | `"/kuflink/ssh/public-keys/DevOpsPublicKey"` |
| `bastion_instance_profile_name` | `string` | IAM instance profile for bastion permissions | `"bastion-instance-profile"` |
| `bastion_name` | `string` | Name tag for bastion instance | `"kuff-staging-bastion"` |
| `ssh_key_name` | `string` | AWS key pair name for SSH access | `"kuflink-keypair"` |
| `bastion_sg_id` | `string` | Security group ID for bastion instance | `"sg-12345678"` |
| `bastion_ami_id` | `string` | AMI ID for bastion instance | `"ami-12345678"` |
| `bastion_elastic_ip_name` | `string` | Name tag for Elastic IP resource | `"kuff-staging-bastion-eip"` |
| `bastion_user_data` | `string` | User data script for instance initialization | `file("user-data/staging.sh")` |
| `instance_type` | `string` | - | `"t3.micro"` | EC2 instance type for bastion |
| `instance_tags` | `map(string)` | Additional tags for bastion instance | `{}`  |

## Outputs

### Infrastructure Outputs

| Output | Type | Description | Usage |
|--------|------|-------------|-------|
| `bastion_elastic_ip` | `string` | Public IP address of the bastion | External client connections, DNS records |
| `bastion_instance_id` | `string` | Instance ID of the bastion host | AWS CLI operations, monitoring setup |
| `bastion_private_ip` | `string` | Private IP address within VPC | Internal routing, security group rules |

### Output Usage Examples

```hcl
# DNS record for staging proxy access
resource "aws_route53_record" "db_proxy" {
  count   = var.environment == "staging" ? 1 : 0
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "kuff-staging-bastion-proxy"
  type    = "A"
  ttl     = 60
  records = [module.staging_bastion.bastion_elastic_ip]
}

# Monitoring alarm for bastion health
resource "aws_cloudwatch_metric_alarm" "bastion_health" {
  alarm_name          = "bastion-health-check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Maximum"
  threshold           = "0"
  
  dimensions = {
    InstanceId = module.bastion.bastion_instance_id
  }
}
```

## Usage Examples

### Staging Environment (MySQL Proxy)

```hcl
module "ec2-bastion" {
  count  = local.enable_bastion ? 1 : 0
  source = "git::ssh://git@github.com/Kuflink/infra-terraformcontrol.git//modules/ec2-bastion?ref=v0.1.60"
  
  # Network configuration
  vpc_id           = data.terraform_remote_state.foundation.outputs.vpc_id
  public_subnet_id = data.terraform_remote_state.foundation.outputs.public_subnet_ids[0]
  bastion_sg_id    = aws_security_group.bastion_sg.id
  
  # Instance configuration
  bastion_name            = "Kuflink-Test-Bastion"
  bastion_elastic_ip_name = "${local.name_prefix}-bastion-ec2-eip"
  instance_type           = "t3.micro"
  bastion_ami_id          = "ami-0f7a692c8af29b5c1"  # Amazon Linux 2
  
  # Access configuration
  ssh_key_name                   = "staging"
  ssh_key_parameter_name         = data.terraform_remote_state.foundation.outputs.ssh_key_parameter_name
  bastion_instance_profile_name  = data.terraform_remote_state.foundation.outputs.bastion_ec2_instance_profile_name
  
  # Environment-specific user data
  bastion_user_data = file("${path.root}/user-data/bastion_user_data.sh")
  
  # Staging-specific instance tags for socat configuration
  instance_tags = {
    Environment  = "staging"
    Purpose      = "mysql-proxy"
    DB_HOST      = local.staging_dns_bastion_target
    FORWARD_PORT = local.forward_port
    TARGET_PORT  = local.target_port
  }
}

# Security group for staging (socat proxy)
resource "aws_security_group" "bastion_staging" {
  name   = "kuff-staging-bastion-sg"
  vpc_id = module.vpc.vpc_id
  
  # Allow socat proxy traffic from external clients
  ingress {
    from_port   = 9990
    to_port     = 9990
    protocol    = "tcp"
    cidr_blocks = [
      "52.56.33.206/32",  # Prod NAT Gateway EIP
      "10.0.0.0/16"       # Internal VPC access
    ]
    description = "MySQL proxy access via socat"
  }
  
  # Allow SSH for administration
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]  # Office IP range
    description = "SSH administrative access"
  }
  
  # Allow outbound to RDS
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "MySQL access to RDS"
  }
  
  # Allow HTTPS for package updates and SSM
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS outbound"
  }
}
```

### Production Environment (Standard Bastion)

```hcl
module "ec2-bastion" {
  count  = local.enable_bastion ? 1 : 0
  source = "git::ssh://git@github.com/Kuflink/infra-terraformcontrol.git//modules/ec2-bastion?ref=v0.1.60"
  
  # Network configuration
  vpc_id           = data.terraform_remote_state.foundation.outputs.vpc_id
  public_subnet_id = data.terraform_remote_state.foundation.outputs.public_subnet_ids[0]
  bastion_sg_id    = aws_security_group.bastion_sg.id
  
  # Instance configuration
  bastion_name            = "Kuflink-Prod-Bastion"
  bastion_elastic_ip_name = "${local.name_prefix}-bastion-ec2-eip"
  instance_type           = "t3.small"
  bastion_ami_id          = "ami-0abcdef1234567890"  # Ubuntu LTS
  
  # Access configuration
  ssh_key_name                   = "production"
  ssh_key_parameter_name         = data.terraform_remote_state.foundation.outputs.ssh_key_parameter_name
  bastion_instance_profile_name  = data.terraform_remote_state.foundation.outputs.bastion_ec2_instance_profile_name
  
  # Environment-specific user data
  bastion_user_data = file("${path.root}/user-data/bastion_user_data.sh")
  
  # Production-specific tags
  instance_tags = {
    Environment = "production"
    Purpose     = "ssh-bastion"
    Backup      = "enabled"
    Monitoring  = "enabled"
  }
}

# Security group for production (SSH only)
resource "aws_security_group" "bastion_prod" {
  name   = "kuff-prod-bastion-sg"
  vpc_id = module.vpc.vpc_id
  
  # Allow SSH from office and VPN
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "203.0.113.0/24",   # Office IP range
      "198.51.100.0/24"   # VPN IP range
    ]
    description = "SSH access from authorized networks"
  }
  
  # Allow outbound for SSH tunnels and updates
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "SSH to internal resources"
  }
  
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for updates and SSM"
  }
}
```
## User Data Configuration

### Test/Staging Environment Script

The test/staging bastion uses a comprehensive script with socat MySQL proxy functionality:

#### Key Features
```bash
#!/bin/bash
set -euo pipefail

# IMDSv2 token handling
get_token() {
  curl -sS -X PUT "http://169.254.169.254/latest/api/token" \
       -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"
}

# Configuration from instance tags
TARGET_HOST="$(imds /latest/meta-data/tags/instance/DB_HOST)"
FORWARD_PORT="$(imds /latest/meta-data/tags/instance/FORWARD_PORT)" 
TARGET_PORT="$(imds /latest/meta-data/tags/instance/TARGET_PORT)"

# Defaults
: "${TARGET_HOST:=kuff-test-mysql.brickfin.co.uk}"
: "${FORWARD_PORT:=9990}"
: "${TARGET_PORT:=3306}"
```

#### SSH Key Management
```bash
# SSH keys from SSM parameters
PUBLIC_KEY_PARAMS=(
  "/kuflink/ssh/public-keys/ArchitectPublicKey"
  "/kuflink/ssh/public-keys/DevOpsPublicKey" 
  "/kuflink/ssh/public-keys/TeamLeadPublicKey"
  "/kuflink/ssh/public-keys/TechLeadPublicKey"
)
```

#### socat SystemD Service
```bash
# Create systemd service for MySQL forwarding
cat >/etc/systemd/system/socat-mysql.service <<'EOF'
[Unit]
Description=Forward port to RDS endpoint via socat
Wants=network-online.target
After=network-online.target

[Service]
EnvironmentFile=/etc/socat/mysql-forward.env
ExecStartPre=/bin/sh -c "DNS wait and loop protection"
ExecStart=/usr/bin/socat TCP-LISTEN:$FORWARD_PORT,reuseaddr,fork TCP:$TARGET_HOST:$TARGET_PORT
Restart=always
RestartSec=2
EOF

systemctl daemon-reload
systemctl enable --now socat-mysql
```

### Production Environment Script

The production bastion uses a minimal Ubuntu setup focused on SSH access:

```bash
#!/bin/bash
set -euo pipefail

echo "🔧 Updating system packages..."
apt-get update -y
apt-get upgrade -y

echo "📦 Installing SSM Agent if not present..."
if ! dpkg -l | grep -q amazon-ssm-agent; then
  snap install amazon-ssm-agent --classic || apt-get install -y amazon-ssm-agent
fi

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

echo "🛠️ Installing useful tools..."
apt-get install -y htop jq unzip curl net-tools

echo "📂 Creating log directories..."
mkdir -p /var/log/kuflink
chown ubuntu:ubuntu /var/log/kuflink

echo "✅ Bastion host is provisioned on Ubuntu with SSM and utilities ready."
```

### Script Differences Summary

| Feature | Test/Staging | Production |
|---------|--------------|------------|
| **OS Package Manager** | `yum` (Amazon Linux 2) | `apt-get` (Ubuntu) |
| **MySQL Proxy** | socat service on port 9990 | Not included |
| **SSH Key Management** | SSM parameter retrieval | Basic SSH setup |
| **Database Connectivity** | MySQL/PostgreSQL clients | Not installed |
| **Service Configuration** | socat systemd service | SSM agent only |
| **Loop Protection** | Prevents self-targeting | Not applicable |
| **Default User** | `ec2-user` | `ubuntu` |


## Security Considerations

### Network Security

#### Staging Environment (MySQL Proxy)
- **Port 9990 exposure**: Restricted to specific external IP addresses
- **RDS access**: Bastion security group only, no direct internet access
- **SSH access**: Limited to administrative networks
- **Loop protection**: Prevents bastion from targeting itself

#### Production Environment (SSH Bastion)
- **SSH access only**: Port 22 from authorized networks
- **No forwarding**: Minimal attack surface
- **Internal connectivity**: SSH tunnels to private resources
- **SSM integration**: Secure management without SSH keys

### Access Control Best Practices

```hcl
# Least privilege security group rules
resource "aws_security_group_rule" "bastion_egress_dns" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "DNS resolution"
}

resource "aws_security_group_rule" "bastion_egress_ntp" {
  type              = "egress"
  from_port         = 123
  to_port           = 123
  protocol          = "udp"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "NTP time synchronization"
}
```

### Key Management

```bash
# SSH key rotation process
aws ssm put-parameter \
  --name "/kuflink/ssh/public-keys/DevOpsPublicKey" \
  --value "$(cat ~/.ssh/new_key.pub)" \
  --type "String" \
  --overwrite

# Instance will pick up new keys on next boot or manual refresh
sudo systemctl restart ssh-key-refresh
```

## Operational Procedures

### Staging Operations (MySQL Proxy)

#### Connection Testing
```bash
# Test proxy connectivity
nc -zv kuff-staging-bastion-proxy.brickfin.co.uk 9990

# Test MySQL connection through proxy
mysql -h kuff-staging-bastion-proxy.brickfin.co.uk -P 9990 \
      -u dbuser -p'password' --ssl -e "SELECT VERSION();"
```

#### Service Management
```bash
# Check socat service status
sudo systemctl status socat-mysql

# View real-time logs
sudo journalctl -u socat-mysql -f

# Restart service after configuration changes
sudo systemctl restart socat-mysql

# Check listening ports
ss -ltnp | grep :9990
```

#### Configuration Updates
```bash
# Edit target configuration
sudo vi /etc/socat/mysql-forward.env

# Example configuration:
# FORWARD_PORT=9990
# TARGET_HOST=kuff-staging-mysql.brickfin.co.uk
# TARGET_PORT=3306

# Apply changes
sudo systemctl restart socat-mysql
```

### Production Operations (SSH Bastion)

#### SSH Access Patterns
```bash
# Direct SSH access
ssh -i ~/.ssh/kuflink.pem ubuntu@bastion-prod.brickfin.co.uk

# SSH tunnel to internal MySQL
ssh -i ~/.ssh/kuflink.pem -L 3306:internal-mysql.local:3306 \
    ubuntu@bastion-prod.brickfin.co.uk

# SSH tunnel to internal application
ssh -i ~/.ssh/kuflink.pem -L 8080:internal-app.local:80 \
    ubuntu@bastion-prod.brickfin.co.uk
```

#### System Monitoring
```bash
# Check system resources
free -m
df -h
htop

# Check SSM agent
sudo systemctl status amazon-ssm-agent

# View system logs
sudo journalctl -n 50
```

## Troubleshooting

### Common Staging Issues

| Symptom | Likely Cause | Diagnostic Commands | Solution |
|---------|--------------|-------------------|----------|
| Connection hangs on port 9990 | Security Group blocking client IP | `tcpdump -nni any 'tcp port 9990'` | Add client's public/NAT IP to bastion SG |
| socat service fails to start | TARGET_HOST resolves to bastion | `journalctl -u socat-mysql` | Fix TARGET_HOST to point to actual RDS |
| MySQL handshake fails | Wrong RDS endpoint or creds | `nc -zv $TARGET_HOST 3306` | Verify RDS endpoint and credentials |
| DNS resolution fails | Route53 misconfiguration | `nslookup kuff-staging-bastion-proxy.brickfin.co.uk` | Check DNS record points to EIP |

### Common Production Issues

| Symptom | Likely Cause | Diagnostic Commands | Solution |
|---------|--------------|-------------------|----------|
| SSH connection refused | Security Group blocking | `aws ec2 describe-security-groups` | Add source IP to SSH rule |
| Can't reach internal resources | Routing or SG issue | `traceroute internal-host` | Check route tables and SGs |
| SSM session fails | IAM permissions | `aws ssm describe-instance-information` | Verify instance profile permissions |
| High CPU usage | Resource constraints | `htop`, `iostat` | Consider larger instance type |

### Diagnostic Commands

#### Staging Diagnostics
```bash
# Service and process checks
sudo systemctl status socat-mysql
pgrep -fa socat
ss -ltnp | grep :9990

# Network connectivity
getent ahostsv4 kuff-staging-mysql.brickfin.co.uk
nc -zv kuff-staging-mysql.brickfin.co.uk 3306

# Configuration verification
cat /etc/socat/mysql-forward.env
sudo cat /proc/$(pidof socat)/cmdline | tr '\0' ' '

# Traffic monitoring
sudo tcpdump -nni any 'tcp port 9990 or tcp port 3306'
```

#### Production Diagnostics
```bash
# System health
systemctl status amazon-ssm-agent
netstat -tlnp | grep :22
ps aux | grep ssh

# Resource monitoring
df -h
free -m
uptime
iotop

# Log analysis
sudo tail -f /var/log/auth.log
sudo journalctl -u ssh -f
```
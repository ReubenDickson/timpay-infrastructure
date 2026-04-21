## TimPay AWS Infrastructure Migration

This repository contains the **Infrastructure as Code (IaC)** used to migrate TimPay's infrastructure from a legacy DigitalOcean environment to a highly available, multi-AZ architecture on AWS.

## 🏗️ Architecture Overview

The system is divided into three logical tiers across three Availability Zones:

* **Public Tier**: Application Load Balancer (ALB) handles incoming HTTPS traffic.
* **Application Tier**: Private EC2 instances managed by an Auto Scaling Group (ASG).
* **Database Tier**: Amazon RDS Multi-AZ instance for high-availability data storage.

The infrastructure is built using a modular Terraform pattern:

* **VPC Module**: Creates a 3-AZ network with public subnets for the Load Balancer and private subnets for the Application and Database tiers.

* **RDS Module**: Deploys a Multi-AZ MySQL 8.0 instance for high availability.

* **Compute Module**: Configures an Application Load Balancer (ALB) and an Auto Scaling Group (ASG) with a self-healing Launch Template.

* **Security**: Implements a "Defense in Depth" strategy using layered Security Groups.

## 📂 Repository Structure

``` bash
timpay-infrastructure/
├── main.tf                 # Root module (orchestrates VPC, RDS, Compute)
├── variables.tf            # Global input definitions
├── outputs.tf              # Final outputs (ALB DNS URL)
├── terraform.tfvars        # Deployment values (Region, Project Name)
├── .gitignore              # Prevents state and secret leaks
└── modules/
    ├── vpc/                # Networking (Subnets, IGW, Route Tables)
    ├── rds/                # Managed Database (Subnet groups, MySQL)
    └── compute/            # ASG, ALB, and userdata.sh bootstrap script

```

## Deployment Instructions

1. Prerequisites
Terraform installed (v1.0+)

AWS CLI configured with appropriate credentials.

2. Initialization
Initialize the backend and download the necessary providers:

``` bash
terraform init
```
3. Configuration
Create a local file named secret.tfvars (this is ignored by Git) to store sensitive information:

Terraform
db_password = "YourSecurePasswordHere"

4. Plan & Apply
Review the execution plan:

``` bash
terraform plan -var-file="secret.tfvars"
```

If the plan looks correct, deploy the infrastructure:

``` bash
terraform apply -var-file="secret.tfvars"
```

## Operational Tasks

Disaster Recovery Drill
To simulate a regional failover, change the aws_region in terraform.tfvars and update the db_snapshot_identifier to restore from the latest cross-region backup.

Scaling
The Auto Scaling Group is configured to maintain a minimum of 2 instances and a maximum of 5. To adjust this, modify the variables in the compute module.

Security
Database: Not accessible from the internet; only accepts traffic from the App Security Group.

Application: Located in private subnets; access is restricted to the Load Balancer.

Secrets: Database passwords are treated as sensitive variables and injected at runtime via User Data.
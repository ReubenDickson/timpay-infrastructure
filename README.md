# TimPay AWS Infrastructure Migration

This repository contains the **Infrastructure as Code (IaC)** used to migrate TimPay's infrastructure from a legacy DigitalOcean environment to a highly available, fault-tolerant, and scalable AWS architecture.

---

## Overview

The goal of this project is to eliminate single points of failure, introduce automated scaling, and enable **zero-downtime migration** to AWS using a reproducible and secure infrastructure model.

Key outcomes:
- High Availability across **three Availability Zones (3-AZ)**
- Fully automated infrastructure using Terraform
- Zero-downtime migration via live database replication
- Secure, production-grade cloud architecture

---

## Architecture Overview

The system is designed using a **three-tier architecture** distributed across **three Availability Zones (AZs)**:

### **1. Public Tier**
- Application Load Balancer (ALB)
- Handles incoming HTTPS traffic
- Performs health checks and routes traffic to healthy instances

### **2. Application Tier**
- EC2 instances running Node.js
- Managed by an Auto Scaling Group (ASG)
- Deployed in **private subnets across 3 AZs**

### **3. Database Tier**
- Amazon RDS (MySQL 8.0)
- Multi-AZ deployment with automatic failover
- Fully isolated in private subnets (no public access)

### **4. Storage Layer**
- Amazon S3 for static assets (images/files)
- Eliminates dependency on instance-local storage

---

## High Availability Strategy (3-AZ Design)

The infrastructure is distributed across **three Availability Zones** to ensure resilience and graceful degradation:

- Failure of one AZ results in ~33% capacity reduction (not 50%)
- Remaining AZs absorb traffic with minimal performance impact
- Auto Scaling dynamically compensates for lost capacity
- No single point of failure at the data center level

---

## Repository Structure

```bash
timpay-infrastructure/
├── main.tf                 # Root module (orchestrates VPC, RDS, Compute)
├── variables.tf            # Global input definitions
├── outputs.tf              # Final outputs (ALB DNS URL)
├── terraform.tfvars        # Deployment values (Region, Project Name)
├── .gitignore              # Prevents state and secret leaks
└── modules/
    ├── vpc/                # Networking (Subnets, IGW, Route Tables)
    ├── rds/                # Managed Database (Subnet groups, MySQL)
    └── compute/            # ASG, ALB, Launch Template, bootstrap scripts
```

## Terraform State Management

Terraform state is stored remotely using an S3 backend with state locking via DynamoDB.

This ensures:

i. Safe team collaboration
ii. State consistency
iii. Prevention of concurrent modifications
iv. Improved reliability in production environments

## Deployment Instructions

1. Prerequisites
Terraform (v1.0+)
AWS CLI configured with appropriate credentials

2. Initialization
``` bash
terraform init
```

3. Configuration

Create a local file named secret.tfvars (ignored by Git):
``` bash
db_password = "YourSecurePasswordHere"
```

4. Plan & Apply
``` bash
terraform plan -var-file="secret.tfvars"
terraform apply -var-file="secret.tfvars"
```

## Zero-Downtime Migration Strategy

This infrastructure supports a zero-downtime migration using a dual-environment approach.

Migration Steps:

i. Deploy AWS Infrastructure
ii. Provision all resources using Terraform
iii. Validate ALB endpoint and application readiness

Database Migration
Use AWS Database Migration Service (DMS)

Enable:
i. Full data load
ii. Change Data Capture (CDC)

Ensure replication lag = 0 before cutover

Static Asset Migration
``` bash
aws s3 sync /local/images s3://your-bucket-name
```

Parallel Environment Execution
Run DigitalOcean and AWS environments simultaneously

DNS Cutover
- Reduce TTL to 60 seconds
- Switch DNS to ALB endpoint

Post-Cutover Monitoring
- Monitor logs, performance, and error rates
- Decommission Legacy Infrastructure only after full validation

Pre-Cutover Validation Checklist
- ALB endpoint returns HTTP 200 OK
- All EC2 instances pass health checks
- Database replication lag = 0
- Application logs show no critical errors
- End-to-end functionality verified

## Rollback Strategy

In case of issues during migration:

- DNS can be reverted to DigitalOcean immediately (low TTL)
- Legacy infrastructure remains active during migration
- Database consistency maintained via replication
- Recovery Time Objective (RTO): < 5 minutes

## Auto Scaling & Performance
- Target tracking scaling policy based on CPU utilization (~60%)
- Even distribution of instances across 3 AZs
- Automatic scale-out during peak load
- Automatic scale-in during low demand

## Monitoring & Observability
- Metrics, dashboards, and alerts via Amazon CloudWatch
- Centralized logging via CloudWatch Logs
- ALB health checks for real-time instance validation

Alerts configured for:
- High CPU usage
- Application errors
- Instance health failures

## Security Architecture

A layered Defense-in-Depth approach is implemented:

- Database in private subnets (no public access)
- Application instances accessible only via ALB
- Security Groups enforce strict traffic control
- IAM roles follow least-privilege principle

## Secrets Management
- Sensitive data managed via AWS Secrets Manager or SSM Parameter Store
- No hard-coded credentials in source code

Encryption
- Data encrypted at rest (RDS, S3)
- Data encrypted in transit (TLS/HTTPS)

Operational Tasks
Scaling: Adjust ASG capacity via variables in the compute module.

## Disaster Recovery Drill
- Restore database from latest snapshot
- Deploy infrastructure in alternate region
- Update DNS to point to new region

## Success Criteria
- Zero seconds of perceived downtime during migration
- Multi-AZ fault tolerance
- Automatic scaling under load
- Fully reproducible infrastructure via Terraform
- Secure and production-ready environment

## Conclusion

This infrastructure transforms TimPay from a fragile, manually managed system into a resilient, scalable, and production-grade cloud platform.

The design ensures:
- Continuous availability
- Data integrity
- Operational transparency
- Future scalability
# terraform-aws-3-tier-architecture

This module contains terraform code to deploy **3 tier architecture** in AWS Cloud provider

It creates a **VPC** with **3 Public** and **3 Private Subnets**.

**Web tier instance** will be deployed in Public Subnet. **App Tier instance** and **RDS Database instance** tier will be deployed in Private subnets

Application Load Balancer routes the incoming traffic to Web tier instance.

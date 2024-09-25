![Image](https://raw.githubusercontent.com/Mo-sayed0/mo/main/Project_Image.jpeg)


# Highly Available 3-Tier AWS Infrastructure

This project uses Terraform to deploy a highly available 3-tier architecture on AWS. The infrastructure includes a VPC with public and private subnets, auto-scaling groups, load balancers, and an RDS instance.

## Architecture Overview

1. **VPC**: A custom VPC with a configurable CIDR block.
2. **Subnets**: 
   - Public subnets for the web tier
   - Private subnets for the application tier
   - Private subnets for the database tier
3. **Internet Gateway**: For public internet access
4. **NAT Gateway**: For private subnets to access the internet
5. **Route Tables**: Separate route tables for public and private subnets
6. **Load Balancers**: 
   - Public Application Load Balancer (ALB) for the web tier
   - Private ALB for the application tier
7. **Auto Scaling Groups**: 
   - For the web tier in public subnets
   - For the application tier in private subnets
8. **RDS**: MySQL database in private subnets
9. **Security Groups**: Separate security groups for web, app, and database tiers

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version 0.12+)
- SSH key pair for EC2 instances

## Usage

1. Clone this repository:
   ```
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Review and modify variables in `variables.tf` as needed.

4. Plan the deployment:
   ```
   terraform plan
   ```

5. Apply the configuration:
   ```
   terraform apply
   ```

6. When prompted, review the planned changes and enter `yes` to proceed.

## Configuration

The main configuration options are defined in `variables.tf`. Key variables include:

- `vpc_name`: Name of the VPC
- `vpc_cidr`: CIDR block for the VPC
- `private_subnet_count`: Number of private subnets for the app tier
- `private_subnet_count_db`: Number of private subnets for the database tier
- `public_subnet_count`: Number of public subnets
- `availability_zones`: List of AZs to use
- `key_name`: Name of the SSH key pair
- `key_path`: Path to the SSH key pair file

## Components

### Networking
- VPC with customizable CIDR block
- Public and private subnets across multiple Availability Zones
- Internet Gateway for public subnets
- NAT Gateway for private subnets
- Route tables for public and private subnets

### Compute
- Launch Templates for web and app tiers
- Auto Scaling Groups for web and app tiers
- Application Load Balancers for web and app tiers

### Database
- RDS MySQL instance in private subnets
- DB Subnet Group for RDS

### Security
- Security Groups for web, app, and database tiers
- Network ACLs (optional, not implemented in the current version)

## Outputs

- `rds_endpoint`: The endpoint of the RDS instance
- `rds_password`: The generated password for the RDS instance (sensitive)

## Security Considerations

- The RDS password is generated randomly and stored in the Terraform state. Ensure your state file is encrypted and stored securely.
- SSH access is restricted to the bastion host (not implemented in this version).
- All resources are created within a VPC for network isolation.

## Scaling and High Availability

- Auto Scaling Groups ensure the desired number of instances are running
- Multi-AZ deployment for RDS provides database redundancy
- Application Load Balancers distribute traffic across multiple instances and AZs

## Cleanup

To destroy the created resources:

```
terraform destroy
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.


# AWS_Secured_project_3-Tier
implement project in AWS console and HCL terraform 


![Image](https://raw.githubusercontent.com/Mo-sayed0/mo/main/Project_Image.jpeg)



# AWS_Secured_project_3-Tier
implement project in AWS console and HCL terraform 

**Situation**
You are tasked with creating a foundational multi-tier architecture in AWS, which includes a Web Tier, Application Tier, and Database Tier. The goal is to build each tier incrementally, ensuring each layer functions correctly before moving on to the next.

**Objective**
Web Tier:
Create a public subnet with a minimum of 2 EC2 instances in an Auto Scaling Group.
Configure a Security Group to allow inbound traffic from the internet.
Deploy a static web page on the EC2 instances.
2.⁠ ⁠Application Tier:

Create private subnets with a minimum of 2 EC2 instances in an Auto Scaling Group.
Configure a Security Group to allow inbound traffic from the Web Server Security Group.
3.⁠ ⁠Database Tier:

Deploy a MySQL RDS instance in private subnets.
Configure a Security Group to allow inbound MySQL traffic from the Application Server Security Group.
Action
1.⁠ ⁠Plan the CIDR Blocks for VPC and Subnets

VPC: 10.0.0.0/16
Public Subnet 1: 10.0.80.0/20
Public Subnet 2: 10.0.96.0/20
Private Subnet 1: 10.0.128.0/20
Private Subnet 2: 10.0.144.0/20
Private Subnet 3: 10.0.160.0/20
Private Subnet 4: 10.0.176.0/20
2.⁠ ⁠Create the VPC and Subnets

Use Terraform or AWS Console to create a VPC and subnets.
3.⁠ ⁠Set Up the Web Tier

Create Public Subnets: Create two public subnets in the VPC.
Public Route Table: Create and associate a public route table with these subnets.
Security Group: Create a Security Group allowing inbound HTTP/HTTPS traffic from the internet.
Launch Configuration and Auto Scaling Group:
Create a launch configuration with a user data script to bootstrap a static web page or use a custom AMI.
Create an Auto Scaling Group with a minimum of 2 instances.
4.⁠ ⁠Verify Web Tier

Access the static web page via the public IP addresses of the EC2 instances.
5.⁠ ⁠Set Up the Application Tier

Create Private Subnets: Create two private subnets in the VPC.
Private Route Table: Create and associate a private route table with these subnets. Add a route to the NAT Gateway for internet access.
Security Group: Create a Security Group allowing inbound traffic from the Web Server Security Group.
Launch Configuration and Auto Scaling Group:
Create a launch configuration for application servers.
Create an Auto Scaling Group with a minimum of 2 instances.
6.⁠ ⁠Set Up the Database Tier

Create MySQL RDS Instance:
Create an RDS instance in one of the private subnets.
Create a Security Group allowing inbound MySQL traffic from the Application Server Security Group.
Multi-AZ Configuration (if needed):
Configure Multi-AZ in the RDS settings for high availability.
7.⁠ ⁠Additional Considerations

NAT Gateway: Create a NAT Gateway in one of the public subnets and update the private route tables accordingly.
Bastion Host or SSM:
Set up a bastion host in the public subnet for SSH access to private instances.
Alternatively, configure AWS Systems Manager (SSM) for accessing instances without a bastion host.
Result
By following this incremental approach, you will have:

A fully functional Web Tier serving a static web page.
An Application Tier prepared to run applications, securely isolated in private subnets.
A Database Tier with a MySQL RDS instance, ready for application data storage.
Ensure to verify the functionality at each step, and deallocate resources like NAT Gateways, Elastic IPs, and ALBs when not in use to avoid unnecessary costs. Document how to add Multi-AZ for RDS instances for future reference.

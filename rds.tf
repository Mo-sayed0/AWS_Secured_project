# Random string for DB password
resource "random_password" "db_password" {
  length  = 16
  special = false
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private_subnets : subnet.id]
  tags = {
    Name = "RDS Subnet Group"
  }
}

# RDS Instance
resource "aws_db_instance" "mysql_rds" {
  count                  = var.private_subnet_count >= 3 ? 1 : 0
  identifier             = "myapp-rds-instance"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "myappdb"
  username               = "admin"
  password               = random_password.db_password.result
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = [aws_security_group.sg_db.id]
  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = true
  tags = {
    Name = "MyApp-RDS-Instance"
  }
}

# Output the RDS endpoint
output "rds_endpoint" {
  value = var.private_subnet_count >= 3 ? aws_db_instance.mysql_rds[0].endpoint : "Not enough private subnets for RDS"
}

# Output the RDS password (Be cautious with this in production environments)
output "rds_password" {
  value     = random_password.db_password.result
  sensitive = true
}

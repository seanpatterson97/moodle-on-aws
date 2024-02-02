############################################
## Create RDS instance
############################################

resource "aws_db_instance" "default" {
  allocated_storage    = 10

  db_name                 = var.db_name
  engine                  = var.db_engine
  engine_version          = "10.11.6"
  instance_class          = var.db_instance_class
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = aws_db_parameter_group.custom_parameter_group.name
  skip_final_snapshot     = true  # required to destroy
  deletion_protection     = var.db_deletion_protection
  db_subnet_group_name    = aws_db_subnet_group.private_subnets.name
  multi_az                = true
  port                    = var.db_port 
  vpc_security_group_ids  = [aws_security_group.rds.id]
}

resource "aws_db_subnet_group" "private_subnets" {
  name       = "private_subnets"
  subnet_ids = aws_subnet.private[*].id # gather all private subnets
}



# need to skip name resolve because we are using private subnets
resource "aws_db_parameter_group" "custom_parameter_group" {
  name   = "custom-parameter-group"
  family = "mariadb10.11"  # Change this to match your DB engine version
  parameter {
    name  = "skip_name_resolve"
    value = "1"
    apply_method = "pending-reboot"
  }
}
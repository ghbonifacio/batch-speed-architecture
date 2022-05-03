#============================================================
#             Metadados Airflow
#============================================================
resource "aws_db_instance" "metadados_airflow" {
  identifier                   = var.rds_identifier_airflow
  instance_class               = "db.t2.micro"
  allocated_storage            = 20
  storage_type                 = "gp2"
  engine                       = "postgres"
  engine_version               = "12.10"
  username                     = var.rds_user_airflow
  password                     = var.rds_password_airflow
  name                         = var.rds_name_airflow
  db_subnet_group_name         = aws_db_subnet_group.default.name
  vpc_security_group_ids       = [aws_security_group.sg_rds_airflow_metadata.id]
  backup_retention_period      = 1
  deletion_protection          = false
  skip_final_snapshot          = true
  publicly_accessible          = false
  performance_insights_enabled = true
  tags                         = var.tags
}
# Create an endpoint for the source database
resource "aws_dms_endpoint" "source" {
  #  certificate_arn = "arn:aws:rds:${var.aws_region}:${var.account_number}:db:${var.source_db_name}"
  database_name = var.source_db_name
  endpoint_id   = var.source_db_id
  endpoint_type = "source"
  engine_name   = var.source_engine_name
  username      = var.source_db_username
  password      = var.source_db_password
  port          = var.source_db_port
  server_name   = var.source_db_endpoint
  # pode ser usado o IP para a conexão.
  ssl_mode = "none"

  tags = {
    Name        = "${var.stack_name}-dms-${var.environment}-source"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "terraform"
  }
}

resource "aws_dms_endpoint" "target" {
  database_name = var.target_db_name
  endpoint_type = "target"
  endpoint_id   = var.target_db_id
  engine_name   = var.target_engine
  #service_access_role = aws_iam_role.dms_endpoint_target_role.arn

  s3_settings {
    service_access_role_arn = aws_iam_role.dms_endpoint_target_role.arn
    bucket_name             = var.target_db_name
    #    bucket_folder           = "raw_zone/"
    compression_type       = "NONE"
    data_format            = "parquet"
    date_partition_enabled = false
    encryption_mode        = "SSE_S3"
    parquet_version        = "parquet-2-0"
  }

  tags = {
    Name        = "${var.stack_name}-dms-${var.environment}-source"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "terraform"
  }

}

# Create a new DMS replication instance
resource "aws_dms_replication_instance" "link" {
  allocated_storage          = var.replication_instance_storage_size
  apply_immediately          = true
  auto_minor_version_upgrade = true
  multi_az                   = false

  publicly_accessible        = true
  replication_instance_class = var.replication_instance_class
  replication_instance_id    = "dms-replication-instance-tf"

  replication_subnet_group_id = "dms-replication-instance-tf"

  #aws_db_subnet_group.dms_subnet_group.name
  vpc_security_group_ids = [var.vpc_sg_dms]

  depends_on = [
    aws_iam_role_policy_attachment.dms_endpoint_target_attachment
  ]

  tags = {
    Name        = "${var.stack_name}-dms-${var.environment}-source"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "terraform"
  }

}

# Create a new replication task
resource "aws_dms_replication_task" "test" {
  migration_type            = "full-load"
  replication_instance_arn  = aws_dms_replication_instance.link.replication_instance_arn
  replication_task_id       = "test-dms-replication-task-tf"
  source_endpoint_arn       = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.target.endpoint_arn
  replication_task_settings = file("replication_task_settings.json")
  table_mappings            = file("table_mapping.json")

  tags = {
    Name        = "${var.stack_name}-dms-${var.environment}-source"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "terraform"
  }

}




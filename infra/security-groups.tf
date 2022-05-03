#============================================================
#             EKS SECURITY GROUPS
#============================================================
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = var.vpc_name  #module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.211.0.0/24",#"10.0.0.0/8",
    ]
  }
}
#============================================================
#             RDS AIRFLOW METADATA SECURITY GROUP
#============================================================
resource "aws_security_group" "sg_rds_airflow_metadata" {
  name        = "sg_vpc"
  description = "Grupo de seguranca do RDS Postgres Airflow Metadata"
  vpc_id      = var.vpc_name
  tags        = var.tags

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "connection"
  }
}
#============================================================
#             RDS METABASE SECURITY GROUP
#============================================================
resource "aws_security_group" "sg_rds_metabase" {
  name        = "sg_db_metabase"
  description = "Grupo de seguranca do RDS Postgres Metabase"
  vpc_id      = var.vpc_name
  tags        = var.tags

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "connection"
  }
}
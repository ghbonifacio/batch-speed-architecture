#============================================================
#             Variaveis Gerais
#============================================================

variable "ambiente" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "aws_region" {
  type = string
}

locals {
  cluster_name = "eks-${var.ambiente}-infra_fintech"
}

#===================================================
#             Variaveis Buckets
#===================================================

variable "bucket_names" {
  type = list(string)
}

variable "bucket_function" {
  type = list(string)
}

#============================================================
#             Variaveis VPC
#============================================================

variable "cidr_vpc" {
  type = string
}

variable "private_subnets_vpc" {
  type = list(string)
}

#variable "public_subnets_vpc" {
#  type = list(string)
#}

variable "vpc_name" {
  type = string
}

#============================================================
#             Variaveis EKS
#============================================================

variable "cluster_version" {
  type = string
}

variable "volume_type" {
  type = string
}

variable "instance_type" {
  type = string
}

#============================================================
#             Variaveis RDS
#============================================================
variable "rds_identifier_airflow" {
  type = string
}

variable "rds_name_airflow" {
  type = string
}

variable "rds_user_airflow" {
  type = string
}

variable "rds_password_airflow" {
  type = string
}

variable "sm_name" {
  type = string
}

variable "sm_description" {
  type = string
}
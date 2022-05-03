#==============================================================
#                General Variables
#==============================================================
aws_region = "us-east-1"

availability_zone = ["us-east-1a","us-east-1b", "us-east-1c",
    "us-east-1d","us-east-1e","us-east-1f"]

ambiente = "homol"

tags = {
    "Ambiente" = "homologação"
    "Versionamento" =  "Terraform"
    "Mantenedor"  = "Data Plataform Engineer "
    "Project" = "Fintech - Anti-Fraud"
}

#===================================================
#             Bucket Variables
#===================================================

bucket_names = ["landing","bronze","silver","gold"]

bucket_function = ["lake","logs"]


#=================================================================
#                          EKS Variables
#=================================================================

cluster_version = "1.21"

volume_type = "gp2"

map_users = [{
    "userarn"  = "arn:aws:iam::account_io:user/user_name_programatic"
    "username" = "user.programatic"
    "groups"   = ["system:masters"]
}]

instance_type = "t2.xlarge"

#===================================================================
#                        VPC variables
#==================================================================

cidr_vpc = "222.222.222.222/222"

private_subnets_vpc = ["subnet-AAAAAAAAA","subnet-BBBBB","subnet-CCCCCC"]

vpc_name = "vpc-id-aws"

#===================================================================
#                        RDS variables
#===================================================================
#airflow metadata
rds_identifier_airflow = "rds_airflow_metadata"
rds_name_airflow = "rds_airflow_metadata"
rds_user_airflow = "user"
rds_password_airflow = "pass"



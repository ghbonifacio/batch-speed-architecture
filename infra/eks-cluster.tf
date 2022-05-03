module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  cluster_endpoint_private_access = "true"

  workers_group_defaults = {
    root_volume_type = var.volume_type
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = var.instance_type
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = var.num_of_nodes
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
  ]

  tags = var.tags

}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}


data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
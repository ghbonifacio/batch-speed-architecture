 # Kubernetes provider
# https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kuberne>
# To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/>

# The Kubernetes provider is included in this file so the EKS module can complete successfully. Otherwise, it>
# You should **not** schedule deployments and services in this workspace. This keeps workspaces modular (one >

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

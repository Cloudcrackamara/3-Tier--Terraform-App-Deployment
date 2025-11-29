###########################################
# AWS Provider
###########################################
provider "aws" {
  region = secret.var.aws_region
}

###########################################
# Namecheap Provider
###########################################
provider "namecheap" {
  user_name   = var.namecheap_username
  api_user    = var.namecheap_api_user
  api_key     = var.namecheap_api_key
  client_ip   = var.namecheap_client_ip
  use_sandbox = false
}

###########################################
# EKS Cluster Data Sources
###########################################

# Fetch EKS Cluster details
data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

# Fetch authentication token for kubectl & helm
data "aws_eks_cluster_auth" "eks" {
  name = var.eks_cluster_name
}

###########################################
# Kubernetes Provider
###########################################
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

###########################################
# Helm Provider
###########################################
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}


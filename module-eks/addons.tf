############################################
# EKS data sources (auth + endpoint)
############################################

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

############################################
# Kubernetes Provider
############################################

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

############################################
# Helm Provider
############################################

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

############################################
# Install NGINX Ingress Controller
############################################

resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.12.0"
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [
    <<EOF
controller:
  service:
    type: LoadBalancer
EOF
  ]
}

############################################
# Discover NGINX Load Balancer (ALWAYS VALID)
############################################

data "aws_lbs" "all" {}

data "aws_lb" "nginx_ingress" {
  depends_on = [helm_release.nginx_ingress]

  arn = element([
    for lb in data.aws_lbs.all.load_balancers : lb.arn
    if contains(lb.arn, "ingress")
  ], 0)
}

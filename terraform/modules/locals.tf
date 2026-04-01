locals {
  cluster_name  = "eks-lab"
  vpc_name      = "eks-vpc"
  domain        = "kolz.link"
  region           = "eu-west-2"
  azs              = ["eu-west-2a", "eu-west-2b"]
  vpc_cidr         = "10.0.0.0/16"
  hosted_zones_arn = "arn:aws:route53:::hostedzone/Z060718917OMF6Y7K0ZKU"

  tags = {
    project = "EKS Advanced Lab"
    Owner   = "Simon"
  }
}
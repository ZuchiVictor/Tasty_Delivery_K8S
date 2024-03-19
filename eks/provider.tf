terraform {
  backend "s3" {
    bucket = "terraform-fiap-rds" # example: terraform-tfstates
    key    = "tastyDelivery/terraform.tfstate"
    region = "us-east-1" # example: us-east-1 (região escolhida na criação do bucket)
  }
}

provider "aws" {
  profile = "default" # trocar pelo profile que tiver, ou retirar se utilizar o aws configure sem um profile
  region  = var.regionDefault

  default_tags {
    tags = var.tags
  }
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "eks-vpc"

  cidr = var.vpcCIDR
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = [aws_db_subnet_group.subnet-eks.id]
  # public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.clusterName}" = "shared"
    "kubernetes.io/role/elb"                   = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.clusterName}" = "shared"
    "kubernetes.io/role/internal-elb"          = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = var.clusterName
  cluster_version = "1.27"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}
  # https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
  # data "aws_iam_policy" "ebs_csi_policy" {
  #   arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  # }

  # module "irsa-ebs-csi" {
  #   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  #   version = "4.7.0"

  #   create_role                   = false
  #   role_name                     = "AmazonEKSClusterPolicy"
  #   provider_url                  = module.eks.oidc_provider
  #   role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  #   oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
  # }

  # resource "aws_eks_addon" "ebs-csi" {
  #   cluster_name             = module.eks.cluster_name
  #   addon_name               = "aws-ebs-csi-driver"
  #   addon_version            = "v1.20.0-eksbuild.1"
  #   service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  #   tags = {
  #     "eks_addon" = "ebs-csi"
  #     "terraform" = "true"
  #   }
  # }

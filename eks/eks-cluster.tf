resource "aws_eks_cluster" "eks" {
    name     = "eks-${var.clusterName}"
    role_arn = "arn:aws:iam::381491872676:role/LabRole"

    vpc_config {
        subnet_ids = [var.subnet01,var.subnet02,var.subnet03]
    }
}
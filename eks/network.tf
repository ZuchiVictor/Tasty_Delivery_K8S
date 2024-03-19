resource "aws_db_subnet_group" "subnet-eks" {
  name       = "subnet-eks-${var.projectName}"
  subnet_ids = ["${var.subnet01}", "${var.subnet02}", "${var.subnet03}"]
}
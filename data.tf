data "aws_db_instance" "rds" {
  db_instance_identifier = "rds-${var.projectName}"
}

# data "aws_ecr_image" "sonar_image" {
#   repository_name = var.projectName
#   image_tag       = "latest"
# }
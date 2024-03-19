resource "aws_ecs_task_definition" "task" {
  family = "TSK-${var.projectName}"
  container_definitions = jsonencode([
    {
      name      = "${var.projectName}"
      essential = true,
      image     = "${aws_ecr_repository.repository.repository_url}:latest",
      # command   = ["-Dsonar.search.javaAdditionalOpts=-Dnode.store.allow_mmap=false"]
      environment = [
        {
          name  = "DB_HOST"
          value = "rds-tasty-delivery.cr6eoyko4hcl.us-east-1.rds.amazonaws.com:5432"
        },
        {
          name  = "DB_USERNAME"
          value = "${var.rdsUser}"
        },
        {
          name  = "DB_PASSWOR"
          value = "${var.rdsPass}"
        },
        {
          name  = "DB_DATABASE"
          value = "${var.dbDatabase}"
        }

      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.cloudwatch-log-group.name}"
          awslogs-region        = "${var.regionDefault}"
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
    }
  ])
  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  execution_role_arn = "arn:aws:iam::${var.AWSAccount}:role/ecsTaskExecutionRole"

  # execution_role_arn = "arn:aws:iam::381491872676:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"

  memory = "4096"
  cpu    = "2048"

  # depends_on = [aws_db_instance.rds]
}
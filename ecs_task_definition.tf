resource "aws_ecs_task_definition" "default" {
  family                   = "${var.namespace}_ECS_TaskDefinition_${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.efs_task_role.arn
  cpu                      = var.cpu_units
  memory                   = var.memory

  container_definitions = jsonencode([
    {
      name         = var.service_name
      image        = "${aws_ecr_repository.ecr.repository_url}:latest"
      user         = "0"
      group        = "0"
      cpu          = var.cpu_units
      memory       = var.memory
      essential    = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "MOODLE_DATABASE_NAME"
          value = var.db_name
        },
        {
          name  = "MOODLE_DATABASE_USER"
          value = var.db_username
        },
        {
          name  = "MOODLE_DATABASE_PASSWORD"
          value = var.db_password
        },
        {
          name  = "MOODLE_DATABASE_ROOT_PASSWORD"
          value = var.db_password
        },
        {
          name  = "MOODLE_DATABASE_HOST"
          value = aws_db_instance.default.address
        },
        {
          name  = "BITNAMI_DEBUG"
          value = "true"
        },
        {
          name  = "MOODLE_SKIP_INSTALL"
          value = "true"
        },
        {
          name  = "MOODLE_DATA_DIR"
          value = "/bitnami/moodledata"
        },
      ]
      mountPoints = [
        {
          sourceVolume  = "moodledata-storage-vol"
          containerPath = "/bitnami/moodledata"
        },
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "${var.service_name}-log-stream-${var.environment}"
        }
      }
    }
  ])

  volume {
    name = "moodledata-storage-vol"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.moodledata-folder.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.moodledata_access_point.id
        iam             = "ENABLED"
      }
    }
  }

  tags = {
    Scenario = var.scenario
  }
}
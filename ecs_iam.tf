########################################################################################################################
## IAM Role for ECS Task execution
########################################################################################################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.namespace}_ECS_TaskExecutionRole_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json

  tags = {
    Scenario = var.scenario
  }
}

data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

########################################################################################################################
## IAM Role for ECS Task
########################################################################################################################

resource "aws_iam_role" "ecs_task_iam_role" {
  name               = "${var.namespace}_ECS_TaskIAMRole_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json

  tags = {
    Scenario = var.scenario
  }
}

########################################################################################################################
## IAM Role for allowing access to EFS on ECS
########################################################################################################################

resource "aws_iam_role" "efs_task_role" {
  name = "efs_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "efs_task_role_policy" {
  name = "efs_task_role_policy"
  role = aws_iam_role.efs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess",
          "elasticfilesystem:DescribeMountTargets",
          "elasticfilesystem:CreateFileSystem",
          "elasticfilesystem:DeleteFileSystems",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
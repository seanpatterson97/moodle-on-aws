########################################################################################################################
## Creates an ECS Cluster
########################################################################################################################

resource "aws_ecs_cluster" "default" {
  name = "${var.namespace}_ECS_Cluster_${var.environment}"

  tags = {
    Name     = "${var.namespace}_ECS_Cluster_${var.environment}"
    Scenario = var.scenario
  }
}

output "cluster_name" {
  value = aws_ecs_cluster.default.name
}
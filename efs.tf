########################################################################################################################
## EFS volume for shared data between containers
####################################################################################################################

resource "aws_efs_file_system" "data-folder" {
  creation_token = "data-folder"
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count            = length(aws_subnet.private[*].id)
  file_system_id   = aws_efs_file_system.data-folder.id
  subnet_id        = element(aws_subnet.private[*].id, count.index)
  security_groups  = [aws_security_group.efs_mount_target_sg.id]
}
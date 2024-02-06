########################################################################################################################
## EFS volume for shared data between containers
####################################################################################################################

resource "aws_efs_file_system" "moodledata-folder" {
  creation_token = "moodledata-folder"
}

resource "aws_efs_mount_target" "moodledata_mount_target" {
  count            = length(aws_subnet.private[*].id)
  file_system_id   = aws_efs_file_system.moodledata-folder.id
  subnet_id        = element(aws_subnet.private[*].id, count.index)
  security_groups  = [aws_security_group.efs_mount_target_sg.id]
}

resource "aws_efs_file_system" "moodle-folder" {
  creation_token = "moodle-folder"
}

resource "aws_efs_mount_target" "moodle_mount_target" {
  count            = length(aws_subnet.private[*].id)
  file_system_id   = aws_efs_file_system.moodle-folder.id
  subnet_id        = element(aws_subnet.private[*].id, count.index)
  security_groups  = [aws_security_group.efs_mount_target_sg.id]
}

########################################################################################################################
## EFS Access points
########################################################################################################################

resource "aws_efs_access_point" "moodledata_access_point" {
  file_system_id = aws_efs_file_system.moodledata-folder.id
  posix_user {
    uid = 0
    gid = 0
  }

  root_directory {
    path = "/"

    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0777"
    }
  }
}

#resource "aws_efs_access_point" "moodle_access_point" {
#  file_system_id = aws_efs_file_system.moodle-folder.id
#
#  posix_user {
#    uid = 0
#    gid = 0
#  }
#
#  root_directory {
#    path = "/"
#
#    creation_info {
#      owner_uid   = 0
#      owner_gid   = 0
#      permissions = "0777"
#    }
#  }
#}
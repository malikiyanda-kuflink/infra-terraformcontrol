# locals.tf
data "aws_region" "current" {}

locals {
  aws_region        = data.aws_region.current.id
  instance_name     = aws_instance.dbt_host.tags["Name"]
  instance_id       = aws_instance.dbt_host.id
  root_volume_id    = aws_instance.dbt_host.root_block_device[0].volume_id
  cwagent_namespace = "CWAgent-${aws_instance.dbt_host.tags["Name"]}-Limited"
  disk_path         = "/"
  disk_device       = "nvme0n1p1"
  disk_fstype       = "ext4"
}


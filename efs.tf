resource "aws_efs_file_system" "efs" {
    creation_token = "${var.stack}"
    encrypted  = true
    throughput_mode = "provisioned"
    provisioned_throughput_in_mibps = "10"
    kms_key_id = aws_kms_key.kms-key.arn
    lifecycle_policy {
        transition_to_ia = "AFTER_30_DAYS"
}
    tags = {
        Name = "${var.stack}"
    
    }
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "efs-target" {
    count           = length(local.pri_subnet_ids)
    file_system_id  = aws_efs_file_system.efs.id
    subnet_id       = "${element(local.pri_subnet_ids, count.index)}"
    security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
    name = "${var.stack}-efs"
    vpc_id = local.vpc_id
    ingress {
        from_port    = 0
        to_port      = 2049
        protocol     = "tcp"
        security_groups = [aws_security_group.web_server_sg.id]
    }
    egress {
        from_port    = 0
        to_port      = 0
        protocol     = "-1"
        cidr_blocks  = ["0.0.0.0/0"]
    }
}


resource "aws_ssm_parameter" "efsvolumeid1" {
    name        = "/${var.stack}/efs_file_system_Id"
    description = "${var.stack} EFS volume ID #1"
    type        = "String"
    value       = aws_efs_file_system.efs.id

    tags = {
        "stack"     = var.stack
}
}


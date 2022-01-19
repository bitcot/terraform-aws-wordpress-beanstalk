locals {
  create_password_secret    = var.password == null && var.create_secretmanager_secret ? true : false
  create_password_parameter = var.password == null && var.create_ssm_secret ? true : false
  final_snapshot_identifier = var.final_snapshot_identifier == null ? "${var.name}-final-snapshot" : var.final_snapshot_identifier
  monitoring_role_arn       = try(aws_iam_role.this[0].arn, var.monitoring_role_arn)
  password                  = try(module.password.secret, random_password.password[0].result, var.password)
  sg_name_prefix            = "${var.name}-access"
  ssm_path                  = coalesce(var.ssm_path, "/db/${var.name}/${var.dbadminuser}-password")

}

resource "aws_db_parameter_group" "default" {
  name   = "rds-db-pg"
  family = var.aws_db_parameter_group_family
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count              = var.monitoring_interval > 0 && var.monitoring_role_arn == null ? 1 : 0
  name_prefix        = var.name
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_db_subnet_group" "aws_subnet_group" {
    name       = "${var.stack}"
    subnet_ids = local.pri_subnet_ids
}

resource "aws_db_instance" "this" {
  identifier                          = "${var.stack}db"
  allocated_storage                   = var.db_storage
  backup_retention_period             = var.backup_retention_period
  copy_tags_to_snapshot               = true
  db_subnet_group_name                = aws_db_subnet_group.aws_subnet_group.id
  deletion_protection                 = var.enable_deletion_protection
  enabled_cloudwatch_logs_exports     = ["audit", "error", "general", "slowquery"]
  engine                              = "mysql"
  engine_version                      = var.engine_version
  final_snapshot_identifier           = local.final_snapshot_identifier
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  allow_major_version_upgrade         = true
  instance_class                      = var.db_instance_class
  monitoring_interval                 = var.monitoring_interval
  monitoring_role_arn                 = local.monitoring_role_arn
  multi_az                            = var.multi_az
  name                                = "${var.stack}db"
  kms_key_id                          = var.kms_key_id
  parameter_group_name                = aws_db_parameter_group.default.id
  password                            = local.password
  performance_insights_enabled        = var.performance_insights_enabled
  port                                = 3306
  skip_final_snapshot                 = var.skip_final_snapshot
  storage_encrypted                   = var.storage_encrypted
  storage_type                        = var.storage_type
  username                            = var.dbadminuser
  vpc_security_group_ids              = [aws_security_group.rds-sg.id]
  apply_immediately                   = true
  tags = {
   "Name" = "${var.stack}-db"
  }
}

resource "aws_security_group" "rds-sg" {
  vpc_id      = aws_default_vpc.default_vpc.id
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [aws_security_group.web_server_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  name = "${var.stack}-rds-sg"
  description = "${var.stack}-rds-sg"
  tags = {
   "stack"     = var.stack
  } 
}


module "password" {
  source  = "rhythmictech/secretsmanager-random-secret/aws"
  version = "~>1.2.0"

  name = "/${var.stack}/rds_password"
  description = "${var.name} database password (username ${var.dbadminuser})"

  create_secret    = local.create_password_secret
  length           = var.password_length
  override_special = "false"
  pass_version     = var.pass_version
  tags             = var.tags
}

resource "random_password" "password" {
  count = local.create_password_parameter ? 1 : 0

  length           = var.password_length
  special          = false
  override_special = ""

  keepers = {
    pass_version = var.pass_version
  }
}

resource "aws_ssm_parameter" "password" {
  count = local.create_password_parameter ? 1 : 0

  name = local.ssm_path

  description = "${var.name} database password (username ${var.dbadminuser})"
  type        = "SecureString"
  value       = random_password.password[0].result

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-pass-secret"
    },
  )
}

resource "aws_ssm_parameter" "dbadminuser" {
name        = "/${var.stack}/dbadminuser"
description = "${var.stack} dbadminuser"
type        = "String"
value       = var.dbadminuser
} 

resource "aws_ssm_parameter" "dbname" {
name        = "/${var.stack}/dbname"
description = "${var.stack} dbname"
type        = "String"
value       = "${var.stack}-db"
} 

resource "aws_ssm_parameter" "dbhostname" {
name        = "/${var.stack}/dbhostname"
description = "${var.stack} dbhostname"
type        = "String"
value       = aws_db_instance.this.address
depends_on  = [aws_db_instance.this] 
} 

resource "aws_ssm_parameter" "dbport" {
name        = "/${var.stack}/dbport"
description = "${var.stack} dbport"
type        = "String"
value       = var.dbport
} 



 

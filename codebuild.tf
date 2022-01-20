# Create CodeBuild resource

resource "aws_codebuild_project" "build" {
  count         = length(var.environment)
  name          = "${var.stack}-${var.environment[count.index]}-codebuild"
  description   = "${var.stack}-${var.environment[count.index]}-codebuild"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.codebuild.arn


  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "NO_CACHE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "stack"
      value = var.stack
    }

    environment_variable {
      name  = "environment"
      value = var.environment[count.index]
    }
    environment_variable {
      name = "dbname"
      value = "${var.stack}-db"
    }
    environment_variable {
      name  = "filesystemid"
      value = aws_efs_file_system.efs.id
    }

  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/${var.stack}/${var.environment[count.index]}-codebuild"
      stream_name = "codebuild"
    }

    s3_logs {
      status = "DISABLED"
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  # vpc_config {
  #   vpc_id             = local.vpc_id
  #   subnets            = local.pri_subnet_ids
  #   security_group_ids = [module.security-group-codebuild.this_security_group_id]
  # }

}

# Create CodeBuild resource

resource "aws_codebuild_project" "build" {
  name          = "${var.stack}-${var.environment}-${var.application}-codebuild"
  description   = "${var.stack}-${var.environment}-${var.application}-codebuild"
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
      value = var.environment
    }
  }

  logs_config {
    # cloudwatch_logs {
    #   group_name  = "/${var.stack}/${var.environment}/codebuild"
    #   stream_name = "codebuild"
    # }

    s3_logs {
      status = "DISABLED"
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  vpc_config {
    vpc_id             = aws_default_vpc.default_vpc.id
    subnets            = local.subnets
    security_group_ids = [module.security-group-codebuild.security_group_id]
  }


}

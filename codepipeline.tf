resource "aws_codepipeline" "codepipeline" {
  name     = "${var.stack}-${var.environment}-${var.application}"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_alias.kms-alias.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        S3Bucket = "${var.stack}-${var.environment}-${var.application}-code-stg"
        S3ObjectKey = "${var.codeprefix}"  # username/reponame/branchname/username_reponame.zip
        PollForSourceChanges = "${var.poll-source-changes}"
      }
    }

    }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      input_artifacts = ["BuildArtifact"]
      version         = "1"

      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.app.name
        # !!! EnvironmentName to be configured correctly, according to Beanstalk configuration !!!
        EnvironmentName = aws_elastic_beanstalk_environment.environment.name
      }
    }
  }

}

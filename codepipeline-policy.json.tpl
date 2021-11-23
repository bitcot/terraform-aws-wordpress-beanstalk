{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "cloudformation.amazonaws.com",
                        "elasticbeanstalk.amazonaws.com",
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:RevokeGrant",
                "logs:*",
                "kms:GenerateDataKey",
                "kms:ReEncryptTo",
                "kms:DescribeKey",
                "kms:CreateGrant",
                "kms:ReEncryptFrom",
                "kms:ListGrants"
            ],
            "Resource": [
                "arn:aws:kms:*:*:key/*",
                "arn:aws:logs:*:*:log-group:*"
            ]
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "logs:GetLogRecord",
                "opsworks:DescribeStacks",
                "devicefarm:GetRun",
                "rds:*",
                "cloudformation:CreateChangeSet",
                "autoscaling:*",
                "logs:ListLogDeliveries",
                "codebuild:BatchGetBuilds",
                "servicecatalog:ListProvisioningArtifacts",
                "devicefarm:ScheduleRun",
                "devicefarm:ListDevicePools",
                "logs:CancelExportTask",
                "cloudformation:UpdateStack",
                "servicecatalog:DescribeProvisioningArtifact",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "devicefarm:ListProjects",
                "logs:DescribeDestinations",
                "sns:*",
                "lambda:ListFunctions",
                "codedeploy:RegisterApplicationRevision",
                "lambda:InvokeFunction",
                "cloudformation:*",
                "opsworks:DescribeDeployments",
                "devicefarm:CreateUpload",
                "logs:StopQuery",
                "logs:CreateLogGroup",
                "cloudformation:DescribeStacks",
                "logs:CreateLogDelivery",
                "codecommit:GetUploadArchiveStatus",
                "logs:PutResourcePolicy",
                "logs:DescribeExportTasks",
                "logs:GetQueryResults",
                "cloudwatch:*",
                "logs:UpdateLogDelivery",
                "cloudformation:DeleteStack",
                "opsworks:DescribeInstances",
                "ecr:DescribeImages",
                "ecs:*",
                "ec2:*",
                "codebuild:StartBuild",
                "cloudformation:ValidateTemplate",
                "opsworks:DescribeApps",
                "opsworks:UpdateStack",
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeploymentConfig",
                "servicecatalog:CreateProvisioningArtifact",
                "sqs:*",
                "logs:GetLogDelivery",
                "cloudformation:DeleteChangeSet",
                "codecommit:GetCommit",
                "logs:DeleteResourcePolicy",
                "servicecatalog:DeleteProvisioningArtifact",
                "logs:DeleteLogDelivery",
                "logs:PutDestination",
                "logs:DescribeResourcePolicies",
                "codedeploy:GetApplication",
                "logs:DescribeQueries",
                "cloudformation:SetStackPolicy",
                "codecommit:UploadArchive",
                "s3:*",
                "logs:PutDestinationPolicy",
                "elasticloadbalancing:*",
                "logs:TestMetricFilter",
                "logs:DeleteDestination",
                "codecommit:CancelUploadArchive",
                "devicefarm:GetUpload",
                "elasticbeanstalk:*",
                "opsworks:UpdateApp",
                "opsworks:CreateDeployment",
                "cloudformation:CreateStack",
                "servicecatalog:UpdateProduct",
                "codecommit:GetBranch",
                "codedeploy:GetDeployment",
                "opsworks:DescribeCommands"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "codestar-connections:UseConnection",
            "Resource": "arn:aws:codestar-connections:${region}:${account_id}:connection/*"
        }
    ]
}
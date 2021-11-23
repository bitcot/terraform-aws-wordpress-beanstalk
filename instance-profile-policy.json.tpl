{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "s3maintain",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObjectVersion",
                "s3:PutObjectVersionAcl",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:GetBucketLocation",
                "s3:GetObjectAcl",
                "s3:PutObjectAcl",
                "s3:PutEncryptionConfiguration",
                "s3:GetEncryptionConfiguration"
            ],
            "Resource": [
                "arn:aws:s3:::${stack}${environment}*",
                "arn:aws:s3:::${stack}${environment}*/*"
            ]
        },
        {
            "Sid": "s3rdslist",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "rds:DescribeDBClusterSnapshots",
                "rds:DescribeEngineDefaultClusterParameters",
                "rds:DescribeDBInstances",
                "rds:DescribeOrderableDBInstanceOptions",
                "rds:DownloadCompleteDBLogFile",
                "rds:DescribeEngineDefaultParameters",
                "rds:DescribeCertificates",
                "rds:DescribeEventCategories",
                "rds:DescribeAccountAttributes"
            ],
            "Resource": "*"
        },
        {
            "Sid": "cloudwatch",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ssmroparameters",
            "Effect": "Allow",
            "Action": [
              "ssm:GetParameter",
              "ssm:GetParameters",
              "ssm:*"
             ],
            "Resource": "arn:aws:ssm:${region}:${account_id}:parameter/${stack}/${environment}/${application}*"
        },
        {
            "Sid": "ssmrwparameter",
            "Effect": "Allow",
            "Action": [
              "ssm:PutParameter"
             ],
            "Resource": "arn:aws:ssm:${region}:${account_id}:parameter/${stack}/${environment}/${application}/dbready"
        },
        {
            "Sid": "rdsaccess",
            "Effect": "Allow",
            "Action": "rds:*",
            "Resource": "*",
            "Condition": {
              "StringEquals": {
                "rds:db-tag/stack": "${stack}",
                "rds:db-tag/environment": "${environment}"
              }
            }
        },
        {
            "Sid": "kmsaccess",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:RevokeGrant",
                "kms:ReEncryptTo",
                "kms:GenerateDataKey",
                "kms:DescribeKey",
                "kms:CreateGrant",
                "kms:ReEncryptFrom",
                "kms:ListGrants"
            ],
            "Resource": "${kms_key_id}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:UpdateInstanceInformation",
                "ssm:ListInstanceAssociations",
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:CreateSecret",
                "secretsmanager:PutSecretValue"
            ],
            "Resource": "arn:aws:secretsmanager:${region}:${account_id}:secret:${stack}-${environment}-${application}-hash_salt*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetEncryptionConfiguration"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowS3ForEBLogs",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::elasticbeanstalk-*",
                "arn:aws:s3:::elasticbeanstalk-*/resources/environments/logs/*"
            ]
        },
        {
            "Sid": "EC2",
            "Action": [
                "ec2:DescribeTags"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ec2:${region}:${account_id}:*",
                "*"
            ]
        },
        {
            "Sid": "Autoscaling",
            "Action": [
                "autoscaling:Describe*"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }

    ]
}
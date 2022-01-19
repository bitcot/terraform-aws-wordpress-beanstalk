# Elastic Beanstalk role and policies

data "template_file" "beanstalk-policy" {
  template = file("${path.module}/beanstalk-policy.json.tpl")

vars = {
  account_id  = data.aws_caller_identity.current.account_id
  region      = var.region_primary
  stack       = var.stack
}
}

resource "aws_iam_policy" "beanstalk" {
name        = "${var.stack}-beanstalk-policy"
description = "${var.stack}-beanstalk-policy"
policy      = data.template_file.beanstalk-policy.rendered
}

data "aws_iam_policy_document" "beanstalk" {
statement {
actions = [
"sts:AssumeRole"
]

principals {
type        = "Service"
identifiers = ["elasticbeanstalk.amazonaws.com"]
}

effect = "Allow"
}
}

resource "aws_iam_role" "beanstalk" {
name        = "${var.stack}-beanstalk"
description = "${var.stack}-beanstalk"

assume_role_policy = data.aws_iam_policy_document.beanstalk.json

# tags = module.ssm_label.tags
}

resource "aws_iam_role_policy_attachment" "beanstalk" {
role       = aws_iam_role.beanstalk.name
policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_policy_attachment" "beanstalk" {
name       = aws_iam_policy.beanstalk.name
roles      = [aws_iam_role.beanstalk.name]
policy_arn = aws_iam_policy.beanstalk.arn
}
### BEGIN KMS

resource "aws_kms_key" "kms-key" {
description         = "${var.stack} KMS Key"
enable_key_rotation = "true"

policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "KMSPolicy",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codestar-notifications.amazonaws.com"
            },
            "Action": [
                "kms:GenerateDataKey*",
                "kms:Decrypt"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "sns.${var.region_primary}.amazonaws.com"
                }
            }
        }
    ]
}
POLICY
# tags = module.ssm_label.tags

}

resource "aws_kms_alias" "kms-alias" {
name          = "alias/${var.stack}-kms-key"
target_key_id = aws_kms_key.kms-key.key_id
}

### END KMS


# EC2 instance profile role and policy

data "template_file" "instance-profile-policy" {
template = file("${path.module}/instance-profile-policy.json.tpl")

vars = {
kms_key_id  = aws_kms_key.kms-key.arn
account_id  = data.aws_caller_identity.current.account_id
region      = var.region_primary
stack       = var.stack
}
}

resource "aws_iam_policy" "instance_profile" {
name        = "${var.stack}-instance-profile-policy"
description = "${var.stack}-instance-profile-policy"
policy      = data.template_file.instance-profile-policy.rendered
}

resource "aws_iam_instance_profile" "instance_profile" {
name = "${var.stack}-instance-profile"
role = aws_iam_role.instance_profile.name
}

resource "aws_iam_role" "instance_profile" {
name = "${var.stack}-instance-profile"

assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
  	  "Action": "sts:AssumeRole",
  	  "Principal": {
  		"Service": "ec2.amazonaws.com"
  	  },
  	  "Effect": "Allow",
  	  "Sid": ""
  	}
  ]
}
EOF
# tags = module.ssm_label.tags
}

resource "aws_iam_policy_attachment" "instance_policy_attach" {
name       = aws_iam_policy.instance_profile.name
roles      = [aws_iam_role.instance_profile.name]
policy_arn = aws_iam_policy.instance_profile.arn
}


# CodeBuild role and policy

data "template_file" "codebuild-policy" {
template = file("${path.module}/codebuild-policy.json.tpl")

vars = {
kms_key_id  = aws_kms_key.kms-key.arn
account_id  = data.aws_caller_identity.current.account_id
region      = var.region_primary
stack       = var.stack
}
}

resource "aws_iam_policy" "codebuild" {
name        = "${var.stack}-codebuild-policy"
description = "${var.stack}-codebuild-policy"
policy      = data.template_file.codebuild-policy.rendered
}

resource "aws_iam_role" "codebuild" {
name        = "${var.stack}-codebuild"
description = "${var.stack}-codebuild"

assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
  	  "Action": "sts:AssumeRole",
  	  "Principal": {
  		"Service": "codebuild.amazonaws.com"
  	  },
  	  "Effect": "Allow",
  	  "Sid": ""
  	}
  ]
}
EOF
# tags = module.ssm_label.tags
}

resource "aws_iam_policy_attachment" "codebuild" {
name       = aws_iam_policy.codebuild.name
roles      = [aws_iam_role.codebuild.name]
policy_arn = aws_iam_policy.codebuild.arn
}

### END: Configure IAM roles, policies, instance profiles

# code build sg
module "security-group-codebuild" {
source  = "terraform-aws-modules/security-group/aws"
version = "3.1.0"

name         = "${var.stack}-codebuild-sg"
description  = "${var.stack}-codebuild-sg"
vpc_id       = local.vpc_id
egress_rules = ["all-all"]
# tags = module.ssm_label.tags
}

resource "aws_s3_bucket" "codepipeline" {
count  = length(var.environment)
bucket = "${var.stack}-${var.environment[count.index]}-codepipeline"
server_side_encryption_configuration {
rule {
apply_server_side_encryption_by_default {
kms_master_key_id = aws_kms_key.kms-key.arn
sse_algorithm     = "aws:kms"
}
}
}

versioning {
enabled = true
}

lifecycle_rule {
enabled = true

noncurrent_version_transition {
days          = 60
storage_class = "STANDARD_IA"
}

noncurrent_version_expiration {
days = 90
}
}

}

### BEGIN SNS notification

data "aws_iam_policy_document" "notification" {
statement {
actions = ["sns:Publish"]

principals {
type        = "Service"
identifiers = ["codestar-notifications.amazonaws.com"]
}

resources = [aws_sns_topic.topic.arn]
}
}

resource "aws_sns_topic_policy" "notification" {
arn    = aws_sns_topic.topic.arn
policy = data.aws_iam_policy_document.notification.json
}

resource "aws_sns_topic" "topic" {
name              = "${var.stack}-topic"
display_name      = "${var.stack}-topic"
kms_master_key_id = aws_kms_key.kms-key.arn

}

resource "aws_sns_topic_subscription" "user_updates_email_target" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = var.sns_email_id
}

resource "aws_codestarnotifications_notification_rule" "pipeline" {
count  = length(var.environment)
detail_type = "BASIC"
event_type_ids = [
"codepipeline-pipeline-action-execution-failed",
"codepipeline-pipeline-action-execution-canceled",
"codepipeline-pipeline-stage-execution-canceled",
"codepipeline-pipeline-stage-execution-failed",
"codepipeline-pipeline-pipeline-execution-failed",
"codepipeline-pipeline-pipeline-execution-canceled",
"codepipeline-pipeline-pipeline-execution-superseded",
"codepipeline-pipeline-manual-approval-failed",
"codepipeline-pipeline-manual-approval-needed"
### added all for now we can uncomment if needed
//    "codepipeline-pipeline-manual-approval-succeeded"
//    "codepipeline-pipeline-action-execution-succeeded"
//    "codepipeline-pipeline-action-execution-started",
//    "codepipeline-pipeline-stage-execution-started",
//    "codepipeline-pipeline-stage-execution-succeeded",
//    "codepipeline-pipeline-stage-execution-resumed",
//    "codepipeline-pipeline-pipeline-execution-started",
//    "codepipeline-pipeline-pipeline-execution-resumed",
//    "codepipeline-pipeline-pipeline-execution-succeeded",
]

name     = "${var.stack}-${var.environment[count.index]}-pipeline-notification"
resource = aws_codepipeline.codepipeline[count.index].arn

target {
address = aws_sns_topic.topic.arn
}
}

resource "aws_codestarnotifications_notification_rule" "build" {
count  =  length(var.environment)
detail_type = "BASIC"
event_type_ids = [
"codebuild-project-build-state-failed",
"codebuild-project-build-phase-failure",
"codebuild-project-build-state-stopped"
//    "codebuild-project-build-state-succeeded",
//    "codebuild-project-build-phase-success"
]

name     = "${var.stack}-${var.environment[count.index]}-build-notification"
resource = aws_codebuild_project.build[count.index].arn

target {
address = aws_sns_topic.topic.arn
}
}

### END SNS notification


#  CodePipeline role and policy

data "template_file" "codepipeline-policy" {
template = file("${path.module}/codepipeline-policy.json.tpl")

vars = {
account_id  = data.aws_caller_identity.current.account_id
region      = var.region_primary
stack       = var.stack
}
}

resource "aws_iam_policy" "codepipeline" {
name        = "${var.stack}-codepipeline-policy"
description = "${var.stack}-codepipeline-policy"
policy      = data.template_file.codepipeline-policy.rendered
}

resource "aws_iam_role" "codepipeline" {
name        = "${var.stack}-codepipeline"
description = "${var.stack}-codepipeline"


assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
  	  "Action": "sts:AssumeRole",
  	  "Principal": {
  		"Service": "codepipeline.amazonaws.com"
  	  },
  	  "Effect": "Allow",
  	  "Sid": ""
  	}
  ]
}
EOF
# tags = module.ssm_label.tags
}

resource "aws_iam_policy_attachment" "codepipeline" {
name       = aws_iam_policy.codepipeline.name
roles      = [aws_iam_role.codepipeline.name]
policy_arn = aws_iam_policy.codepipeline.arn
}


resource "aws_security_group" "web_server_sg" {
  name = "${var.stack}-webserver-sg"
  vpc_id = local.vpc_id
    ingress {
        from_port    = 443
        to_port      = 443
        protocol     = "tcp"
        security_groups = [aws_security_group.allow_tls.id]
    }
    ingress {
        from_port    = 80
        to_port      = 80
        protocol     = "tcp"
        security_groups = [aws_security_group.allow_tls.id]
    }
    egress {
        from_port    = 0
        to_port      = 0
        protocol     = "-1"
        cidr_blocks  = ["0.0.0.0/0"]
    }
}


resource "aws_security_group" "allow_tls" {
  name = "${var.stack}-ELB-sg"
  vpc_id = local.vpc_id
    ingress {
        from_port    = 443
        to_port      = 443
        protocol     = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]
    }
    ingress {
        from_port    = 80
        to_port      = 80
        protocol     = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]  
    }
    egress {
        from_port    = 0
        to_port      = 0
        protocol     = "-1"
        cidr_blocks  = ["0.0.0.0/0"]
    }
}


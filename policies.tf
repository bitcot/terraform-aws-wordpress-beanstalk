# Elastic Beanstalk role and policies

data "template_file" "beanstalk-policy" {
  template = file("${path.module}/beanstalk-policy.json.tpl")

vars = {
  account_id  = data.aws_caller_identity.current.account_id
  region      = var.region_primary
  stack       = var.stack
  environment = var.environment
  application = var.application
}
}

resource "aws_iam_policy" "beanstalk" {
name        = "${var.stack}-${var.environment}-${var.application}-beanstalk-policy"
description = "${var.stack}-${var.environment}-${var.application}-beanstalk-policy"
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
name        = "${var.stack}-${var.environment}-${var.application}-beanstalk"
description = "${var.stack}-${var.environment}-${var.application}-beanstalk"

assume_role_policy = data.aws_iam_policy_document.beanstalk.json


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
description         = "${var.stack} ${var.environment} KMS Key"
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


}

resource "aws_kms_alias" "kms-alias" {
name          = "alias/${var.stack}-${var.environment}-${var.application}-kms-key"
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
environment = var.environment
application = var.application
}
}

resource "aws_iam_policy" "instance_profile" {
name        = "${var.stack}-${var.environment}-${var.application}-instance-profile-policy"
description = "${var.stack}-${var.environment}-${var.application}-instance-profile-policy"
policy      = data.template_file.instance-profile-policy.rendered
}

resource "aws_iam_instance_profile" "instance_profile" {
name = "${var.stack}-${var.environment}-${var.application}-instance-profile"
role = aws_iam_role.instance_profile.name
}

resource "aws_iam_role" "instance_profile" {
name = "${var.stack}-${var.environment}-${var.application}-instance-profile"

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
environment = var.environment
application = var.application
}
}

resource "aws_iam_policy" "codebuild" {
name        = "${var.stack}-${var.environment}-${var.application}-codebuild-policy"
description = "${var.stack}-${var.environment}-${var.application}-codebuild-policy"
policy      = data.template_file.codebuild-policy.rendered
}

resource "aws_iam_role" "codebuild" {
name        = "${var.stack}-${var.environment}-${var.application}-codebuild"
description = "${var.stack}-${var.environment}-${var.application}-codebuild"

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
version = "4.4.0"

name         = "${var.stack}-${var.environment}-${var.application}-codebuild-sg"
description  = "${var.stack}-${var.environment}-${var.application}-codebuild-sg"
vpc_id       = aws_default_vpc.default_vpc.id
egress_rules = ["all-all"]

}

resource "aws_s3_bucket" "codepipeline" {
bucket = "${var.stack}${var.environment}-codepipeline"
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


# BEGIN ACM ertificate

resource "aws_acm_certificate" "certificate" {
domain_name       = var.domain_name
validation_method = "DNS"

tags = {
"stack"     = "${var.stack}"
"stack_env" = "${var.environment}"
}

lifecycle {
create_before_destroy = true
}
}

resource "aws_acm_certificate_validation" "certificate" {
certificate_arn = aws_acm_certificate.certificate.arn
timeouts {
create = "60m"
}
}

# END Certificate

# BEGIN ACM certificate for Cloudfront

resource "aws_acm_certificate" "cert_cloudfront" {
domain_name       = var.domain_name_cloudfront
validation_method = "DNS"
provider = aws.for_acm
tags = {
"stack"     = "${var.stack}"
"stack_env" = "${var.environment}"
}

lifecycle {
create_before_destroy = true
}
}

resource "aws_acm_certificate_validation" "cert_cloudfront" {
certificate_arn = aws_acm_certificate.cert_cloudfront.arn
provider = aws.for_acm
timeouts {
create = "60m"
}
}

#  CodePipeline role and policy

data "template_file" "codepipeline-policy" {
template = file("${path.module}/codepipeline-policy.json.tpl")

vars = {
account_id  = data.aws_caller_identity.current.account_id
region      = var.region_primary
stack       = var.stack
environment = var.environment
application = var.application
}
}

resource "aws_iam_policy" "codepipeline" {
name        = "${var.stack}-${var.environment}-${var.application}-codepipeline-policy"
description = "${var.stack}-${var.environment}-${var.application}-codepipeline-policy"
policy      = data.template_file.codepipeline-policy.rendered
}

resource "aws_iam_role" "codepipeline" {
name        = "${var.stack}-${var.environment}-${var.application}-codepipeline"
description = "${var.stack}-${var.environment}-${var.application}-codepipeline"


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

}

resource "aws_iam_policy_attachment" "codepipeline" {
name       = aws_iam_policy.codepipeline.name
roles      = [aws_iam_role.codepipeline.name]
policy_arn = aws_iam_policy.codepipeline.arn
}

## Security groups

module "security-group-webserver" {
source      = "terraform-aws-modules/security-group/aws"
version     = "4.4.0"
name        = "${var.stack}-${var.environment}-${var.application}-webserver-sg"
description = "${var.stack}-${var.environment}-${var.application}-webserver-sg"
vpc_id      = aws_default_vpc.default_vpc.id
ingress_with_source_security_group_id = [
{
rule                     = "all-all"
description              = "local-access"
source_security_group_id = "${module.security-group-webserver.security_group_id}"
},
{
rule                     = "http-80-tcp"
description              = "http-from-elb"
source_security_group_id = "${module.security-group-elb.security_group_id}"
},
{
rule                     = "https-443-tcp"
description              = "https-from-elb"
source_security_group_id = "${module.security-group-elb.security_group_id}"
}
]
egress_rules = ["all-all"]

}
module "security-group-elb" {
source      = "terraform-aws-modules/security-group/aws"
version     = "4.4.0"
name        = "${var.stack}-${var.environment}-${var.application}-elb-sg"
description = "${var.stack}-${var.environment}-${var.application}-elb-sg"
vpc_id      = aws_default_vpc.default_vpc.id

ingress_cidr_blocks = var.whitelist
ingress_rules       = ["https-443-tcp", "http-80-tcp"]
egress_rules        = ["all-all"]
ingress_with_source_security_group_id = [
{
rule                     = "all-all"
description              = "local-access"
source_security_group_id = "${module.security-group-elb.security_group_id}"
}
]

}

### HTTP  rediect to HTTPS
resource "aws_lb_listener" "https_redirect" {
load_balancer_arn = aws_elastic_beanstalk_environment.environment.load_balancers[0]
port              = 80
protocol          = "HTTP"

default_action {
type = "redirect"

redirect {
port        = "443"
protocol    = "HTTPS"
status_code = "HTTP_301"
}
}
}

data "aws_lb" "eb_lb" {
arn = aws_elastic_beanstalk_environment.environment.load_balancers[0]
}

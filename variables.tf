
################################
# General vars                 #
################################
variable "stack" {
  type        = string
  description = "Defines the application stack to which this component is related. (e.g AirView, PivotalCloud, Exchange)"
}

# environment tags
variable "environment" {
  type        = list
  description = "Enter the list of App environment"  # Eg: ["stg","prod"]
}

variable "access_key" {
  type = string
  description = "Enter the access key"
}
variable "secret_key" {
  type = string
  description = "Enter the secret key"
}
variable "region_primary" {
  type    = string
  description = "Enter the region name"
}

####################################
# ELB variables                    #
####################################

variable "sslpolicy" {
  description = "EB - ELB Security Policy"
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  type        = string
}

variable "elb_certificate_arn" {
  type        = string
  description = "ELB certificate arn"
  default     = ""
}

variable "elb_domains" {
  type = list(string)
  description = "Enter the list of ELB domains"
}

#####################################
# Beanstalk variables               #
#####################################

variable "healthcheckpath" {
  description = "Load Balancer healthcheck path"
  type        = string
  default     = "/"
}

variable "stickinesslbcookieduration" {
  description = "EB - ELB stickiness cookie duration"
  default     = "3600"
  type        = string
}

variable "autoscaling_instance_type" {
  description = "EB autoscaling launch config instance type"
  type        = string
  default     = ""                      #"t2.medium"
}

variable "root_volume_size" {
  description = "Size of root volume of autoscaling launch config instance"
  type        = string
  default     = 30 
}
variable "root_volume_type" {
  description = "Type of root volume of autoscaling lauch config instance"
  type        = string
  default     = "gp2"
}

variable "enhanced_reporting_enabled" {
  description = "EB enhanced healthreporting enabled"
  default     = "true"
  type        = string
}
variable "healthcheck_success_threshold" {
  description = "EB treshold to pass healthcheck"
  default     = "Ok"
  type        = string
}

variable "deployment_policy" {
  description = "EB deployment policy Eg: Rolling, Immutable"
  default     = "Immutable"
  # default     = "Rolling"
  type        = string
}

variable "deployment_timeout" {
  description = "EB rolling deployment timeout"
  default     = "600"
  type        = string
}

variable "deployment_batchsizetype" {
  description = "EB rolling deployment batch size type"
  default     = "Percentage"
  type        = string
}

variable "deployment_batchsize" {
  description = "EB rolling deployment batch size"
  default     = "100"
  type        = string
}

variable "deployment_ignorehealthcheck" {
  description = "EB rolling deployment ignore healthcheck"
  default     = "true"
  type        = string
}

variable "rolling_update_enabled" {
  description = "EB autoscaling rolling update enabled"
  default     = "true"
  type        = string
}

variable "rolling_update_type" {
  description = "EB autoscaling rolling update type"
  default     = "Time"
  type        = string
}


variable "updating_min_in_service" {
  description = "EB rolling update minimum number of instances in service"
  default     = "2"
  type        = string
}

variable "managedactionsenabled" {
  description = "EB managed platform updates enabled"
  default     = "true"
  type        = string
}

variable "preferred_start_time" {
  description = "EB rolling update preferred start time"
  default     = "Sat:04:00"
  type        = string
}

variable "update_level" {
  description = "EB highest level of update to apply - patch/minor"
  default     = "minor"
  type        = string
}

variable "instance_refresh_enabled" {
  description = "EB - enable weekly instance replacement"
  default     = "true"
  type        = string
}
variable "autoscaling_minsize" {
  description = "EB autoscaling launch config minimum size"
  default     = "1"
  type        = string
}

variable "autoscaling_maxsize" {
  description = "EB autoscaling launch config maximum size"
  default     = "4"
  type        = string
}

variable "autoscale_measure_name" {
  type        = string
  default     = "CPUUtilization"
  description = "Metric used for your Auto Scaling trigger"
}

variable "autoscale_statistic" {
  type        = string
  default     = "Average"
  description = "Statistic the trigger should use, such as Average"
}

variable "autoscale_unit" {
  type        = string
  default     = "Percent"
  description = "Unit for the trigger measurement, such as Bytes"
}

variable "autoscale_lower_bound" {
  type        = number
  default     = 20
  description = "Minimum level of autoscale metric to remove an instance"
}

variable "autoscale_lower_increment" {
  type        = number
  default     = -1
  description = "How many Amazon EC2 instances to remove when performing a scaling activity."
}

variable "autoscale_upper_bound" {
  type        = number
  default     = 50
  description = "Maximum level of autoscale metric to add an instance"
}

variable "autoscale_upper_increment" {
  type        = number
  default     = 1
  description = "How many Amazon EC2 instances to add when performing a scaling activity"
}

variable "cloudwatch_log_retention" {
  description = "Number of days to keep log events before they expire"
  default     = "14"
}
variable "document_root" {
  description = "document root for php software"
  default     = "/"
  type        = string
}
variable "memory_limit" {
  description = "memory limit for php software"
  default     = "512M"
  type        = string
}
variable "max_execution_time" {
  description = "maximum execution time"
  default     = 600
  type        = string
}

#############################
# Codebuild variables       #
#############################
variable "build_timeout" {
  description = "CodeBuild build timeout in minutes"
  default     = "10"
}


# RDS variables
########################################
# General Vars
########################################

variable "iops" {
  type        = number
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'. Default is 0 if rds storage type is not 'io1'"
  default     = 0
}
variable "aws_db_parameter_group_family" {
  type = string
  description = "aws_db_parameter_group_family version we need to pass here for ex: mysql5.7, mysql8.0"
}



variable "max_allocated_storage" {
  type        = number
  description = "Configuring this will automatically ignore differences to allocated_storage. Must be greater than or equal to allocated_storage or 0 to disable Storage Autoscaling"
  default     = 0
}

variable "name" {
  default     = "mysql"
  description = "common name for resources in this module"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to apply to supported resources"
  type        = map(string)
}


########################################
# Access Control Vars
########################################

variable "allowed_cidr_blocks" {
  default     = []
  description = "CIDR blocks allowed to reach the database"
  type        = list(string)
}

variable "allowed_ipv6_cidr_blocks" {
  default     = []
  description = "IPv6 CIDR blocks allowed to reach the database"
  type        = list(string)
}

variable "allowed_security_groups" {
  default     = []
  description = "IDs of security groups allowed to reach the database (not Names)"
  type        = list(string)
}




########################################
# DB Authentication Vars
########################################

variable "create_secretmanager_secret" {
  default     = true
  description = "True to create a secretmanager secret containing DB password (not used if `password` is set)"
  type        = bool
}

variable "create_ssm_secret" {
  default     = false
  description = "True to create a SSM Parameter SecretString containing DB password (not used if `password` is set)"
  type        = bool
}

variable "password" {
  default     = null
  description = "Master password (if not set, one will be generated dynamically)"
  type        = string
}

variable "password_length" {
  default     = 16
  description = "Master password length (not used if `password` is set)"
  type        = number
}

variable "pass_version" {
  default     = 1
  description = "Increment to force master user password change (not used if `password` is set)"
  type        = number
}

variable "ssm_path" {
  default     = ""
  description = "Custom path for SSM parameter, only takes effect if `create_ssm_secret` is true. "
  type        = string
}

# RDS vars

########################################
# Database Config Vars
########################################

variable "backup_retention_period" {
  default     = 5
  description = "How long to keep RDS backups (in days)"
  type        = string
}

variable "cloudwatch_log_exports" {
  description = "Log types to export to CloudWatch"
  type        = list(string)

  default = [
    "mysql",
    "upgrade"
  ]
}

variable "enable_deletion_protection" {
  default     = false
  description = "If `true`, deletion protection will be turned on for the RDS instance(s)"
  type        = bool
}

variable "engine_version" {
  description = "Version of database engine to use ex: 5.5.6, 8.0"
  type        = string
}

variable "final_snapshot_identifier" {
  default     = null
  description = "name of final snapshot (will be computed automatically if not specified)"
  type        = string
}

variable "iam_database_authentication_enabled" {
  default     = false
  description = "True to enable IAM DB authentication"
  type        = bool
}

variable "parameters" {
  description = "Database parameters (will create parameter group if not null)"

  default = [
    {
      name  = "client_encoding"
      value = "UTF8"
    }
  ]

  type = list(object({
    name  = string
    value = string
  }))
}

variable "parameter_group_family" {
  default     = ""
  description = "Parameter Group Family. Need to make explicit for Postgres 9.x"
  type        = string
}

variable "performance_insights_enabled" {
  default     = false
  description = "If true, performance insights will be enabled"
  type        = bool
}

variable "skip_final_snapshot" {
  default     = false
  description = "If true no final snapshot will be taken on termination"
  type        = bool
}

variable "dbadminuser" {
  description = "Username of master user"
  type        = string
 
}

variable "dbport" {
  description = "Username of master user"
  type        = string
  default     = 3306
}

########################################
# Instance Vars
########################################

variable "identifier" {
  default     = null
  description = "DB identifier (not recommended, only used if `identifier_prefix` is not null)"
  type        = string
}

variable "identifier_prefix" {
  default     = null
  description = "DB identifier prefix (will be generated by AWS automatically if not specified)"
  type        = string
}

variable "db_instance_class" {
  description = "What instance type to use"
  type        = string
}

variable "monitoring_interval" {
  default     = 0
  description = "Monitoring interval in seconds (`0` to disable enhanced monitoring)"
  type        = number
}

variable "monitoring_role_arn" {
  default     = null
  description = "Enhanced Monitoring ARN (if `monitoring_interval > 0` and this is omitted, a role will be created automatically)"
  type        = string
}

variable "multi_az" {
  default     = true
  description = "whether to make database multi-az"
  type        = bool
}

variable "db_storage" {
  description = "How much storage is available to the database"
  type        = string
  default = "30"
}

variable "storage_encrypted" {
  default     = false
  description = "Encrypt DB storage"
  type        = bool
}
variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. If creating an encrypted replica, set this to the destination KMS ARN. If storage_encrypted is set to true and kms_key_id is not specified the default KMS key created in your account will be used"
  type        = string
  default     = null
}

variable "storage_type" {
  default     = "gp2"
  description = "What storage backend to use (`gp2` or `standard`. io1 not supported)"
  type        = string
}


#####################################
# CDN variables                     #
#####################################
variable "domain_name_cloudfront" {
  description = "Alias Domain name for cloudfront "
  default     = ""
  type        = string
}

variable "minimum_client_tls_protocol_version" {
  type        = string
  description = "CloudFront viewer certificate minimum protocol version"
  default     = "TLSv1"
}
variable "cdn_cert_arn" {
  type        = string
  description = "Enter Cloudfront certificate arn"
  default     = "" 
}


##############################
# Codepipeline variables     #
##############################
variable "S3ObjectKey" {
  description = "map for source branches"
  type = map
  default = {
    "php" = "devtest"
    #"stg" = "stgtest"
  }

}
variable "poll-source-changes" {
  default     = "true"
  description = "Set whether the created pipeline should poll the source for change and triggers the pipeline"
}

###############################
# SNS variable                #
###############################
variable "sns_email_id" {
  description = "Enter the sns email id"
  type = string
}



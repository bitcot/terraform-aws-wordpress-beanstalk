
data "aws_caller_identity" "current" {
}


locals {
  subnets = [aws_default_subnet.default_subnet_a.id,aws_default_subnet.default_subnet_b.id,aws_default_subnet.default_subnet_c.id]
}


# data "aws_elastic_beanstalk_solution_stack" "php" {
#   most_recent = true
#   name_regex = "^64bit Amazon Linux 2 (.*) running PHP 7.4(.*)$"
# }


resource "aws_elastic_beanstalk_application" "app" {
  name        = "${var.stack}-${var.environment}-${var.application}"
  description = "${var.stack}-${var.environment}-${var.application}-application"
  appversion_lifecycle {
    service_role          = aws_iam_role.beanstalk.arn
    max_count             = 20
    delete_source_from_s3 = true
  }

  tags = {
    "stack"     = var.stack
    "stack_env" = var.environment
  }
}

resource "aws_elastic_beanstalk_environment" "environment" {
  name                = "${var.stack}-${var.environment}-${var.application}-env"
  application         = aws_elastic_beanstalk_application.app.name
  #solution_stack_name  = data.aws_elastic_beanstalk_solution_stack.php.name
  solution_stack_name  = "64bit Amazon Linux 2 v3.3.8 running PHP 7.4"
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.beanstalk.name
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value = aws_default_vpc.default_vpc.id
  }

  # You need to define which subnets, unfortunately
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value = join(",", local.subnets)
}

setting {
  namespace = "aws:ec2:vpc"
  name      = "ELBSubnets"
  value     = join(",", local.subnets)
}
setting {
namespace = "aws:elbv2:listener:default"
name      = "ListenerEnabled"
value     = "false"
}

setting {
namespace = "aws:elbv2:listener:443"
name      = "ListenerEnabled"
value     = "true"
}

setting {
namespace = "aws:elbv2:listener:443"
name      = "Protocol"
value     = "HTTPS"
}

setting {
namespace = "aws:elbv2:listener:443"
name      = "SSLCertificateArns"
value     = aws_acm_certificate_validation.certificate.certificate_arn
}

setting {
namespace = "aws:elbv2:listener:443"
name      = "SSLPolicy"
value     = var.sslpolicy
}

setting {
namespace = "aws:elb:policies"
name      = "ConnectionDrainingEnabled"
value     = "true"
}

setting {
namespace = "aws:elb:policies"
name      = "ConnectionDrainingTimeout"
value     = "30"
}

setting {
namespace = "aws:elb:policies"
name      = "ConnectionSettingIdleTimeout"
value     = "60"
}

setting {
namespace = "aws:elb:policies"
name      = "Stickiness Policy"
value     = "true"
}

setting {
namespace = "aws:elb:policies"
name      = "Stickiness Cookie Expiration"
value     = "300"
}

setting {
namespace = "aws:elasticbeanstalk:healthreporting:system"
name      = "ConfigDocument"
value = jsonencode({
      "CloudWatchMetrics" : {
        "Environment" : {
          "ApplicationRequestsTotal" : 60,
          "ApplicationRequests4xx" : 60,
          "ApplicationRequests5xx" : 60,
          "ApplicationLatencyP99.9" : 60
        },
        "Instance" : {
          "LoadAverage1min" : 60
        }
      },
      "Rules": {
  "Environment": {
    "ELB": {
      "ELBRequests4xx": {
        "Enabled": false
      }
    },
    "Application": {
      "ApplicationRequests4xx": {
        "Enabled": false
      }
    }
  }
},
      "Version" : 1
    })
    resource = ""
  }
setting {
namespace = "aws:elasticbeanstalk:cloudwatch:logs"
name      = "StreamLogs"
value     = "true"
resource  = ""
  }

setting {
namespace = "aws:elasticbeanstalk:cloudwatch:logs"
name      = "RetentionInDays"
value     = var.cloudwatch_log_retention
resource  = ""
  }

setting {
namespace = "aws:elasticbeanstalk:cloudwatch:logs"
name      = "DeleteOnTerminate"
value     = "true"
resource  = ""
  }

setting {
namespace = "aws:elasticbeanstalk:customoption"
name      = "CloudWatchMetrics"
value     = "--mem-util --mem-used --mem-avail --disk-space-util --disk-space-used --disk-space-avail --disk-path=/ --auto-scaling"
resource  = ""
  }

setting {
namespace = "aws:elasticbeanstalk:environment"
name      = "LoadBalancerType"
value     = "application"
}


setting {
namespace = "aws:elasticbeanstalk:environment:process:default"
name      = "HealthCheckPath"
value     = var.healthcheckpath
}

setting {
namespace = "aws:elasticbeanstalk:environment:process:default"
name      = "StickinessEnabled"
value     = "true"
}

setting {
namespace = "aws:elasticbeanstalk:environment:process:default"
name      = "StickinessLBCookieDuration"
value     = var.stickinesslbcookieduration
}

setting {
namespace = "aws:elasticbeanstalk:environment:process:default"
name      = "StickinessType"
value     = "lb_cookie"
}

setting {
namespace = "aws:elasticbeanstalk:application:environment"
name      = "stack"
value     = var.stack
}

setting {
namespace = "aws:elasticbeanstalk:application:environment"
name      = "environment"
value     = var.environment
}
setting {
namespace = "aws:autoscaling:launchconfiguration"
name      = "IamInstanceProfile"
value     = aws_iam_instance_profile.instance_profile.name
}
setting {
  namespace = "aws:autoscaling:launchconfiguration"
  name      = "RootVolumeSize"
  value     = var.root_volume_size
  resource  = ""
}
setting {
  namespace = "aws:autoscaling:launchconfiguration"
  name      = "RootVolumeType"
  value     = var.root_volume_type
  resource  = ""
}


setting {
namespace = "aws:autoscaling:launchconfiguration"
name      = "InstanceType"
value     = var.autoscaling_instance_type
}

setting {
namespace = "aws:autoscaling:asg"
name      = "MinSize"
value     = var.autoscaling_minsize
}

setting {
namespace = "aws:autoscaling:asg"
name      = "MaxSize"
value     = var.autoscaling_maxsize
}

setting {
namespace = "aws:elasticbeanstalk:healthreporting:system"
name      = "SystemType"
value     = var.enhanced_reporting_enabled ? "enhanced" : "basic"
}

setting {
namespace = "aws:elasticbeanstalk:healthreporting:system"
name      = "HealthCheckSuccessThreshold"
value     = var.healthcheck_success_threshold
}
#securitygroups

setting {
namespace = "aws:elbv2:loadbalancer"
name      = "SecurityGroups"
value     = module.security-group-elb.security_group_id
}
setting {
namespace = "aws:autoscaling:launchconfiguration"
name      = "SecurityGroups"
value     = module.security-group-webserver.security_group_id
}

# Configure rolling deployments - begin
setting {
namespace = "aws:elasticbeanstalk:command"
name      = "DeploymentPolicy"
value     = var.deployment_policy
}

setting {
namespace = "aws:elasticbeanstalk:command"
name      = "Timeout"
value     = var.deployment_timeout
}


setting {
namespace = "aws:elasticbeanstalk:command"
name      = "BatchSizeType"
value     = var.deployment_batchsizetype
}

setting {
namespace = "aws:elasticbeanstalk:command"
name      = "BatchSize"
value     = var.deployment_batchsize
}

setting {
namespace = "aws:elasticbeanstalk:command"
name      = "IgnoreHealthCheck"
value     = var.deployment_ignorehealthcheck
}
# Configure rolling deployments - end

# Configure rolling updates - begin
setting {
namespace = "aws:autoscaling:updatepolicy:rollingupdate"
name      = "RollingUpdateEnabled"
value     = var.rolling_update_enabled
}

setting {
namespace = "aws:autoscaling:updatepolicy:rollingupdate"
name      = "RollingUpdateType"
value     = var.rolling_update_type
}

setting {
namespace = "aws:autoscaling:updatepolicy:rollingupdate"
name      = "MinInstancesInService"
value     = var.updating_min_in_service
}
# Configure rolling updates - end

# Configure managed updates - begin
setting {
namespace = "aws:elasticbeanstalk:managedactions"
name      = "ManagedActionsEnabled"
value     = var.managedactionsenabled
}

setting {
namespace = "aws:elasticbeanstalk:managedactions"
name      = "PreferredStartTime"
value     = var.preferred_start_time
}

setting {
namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
name      = "UpdateLevel"
value     = var.update_level
}

setting {
namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
name      = "InstanceRefreshEnabled"
value     = var.instance_refresh_enabled
}

setting {
namespace = "aws:elasticbeanstalk:application:environment"
name      = "dbhostname"
value     = aws_db_instance.this.address
}

# ASG trigger for beanstalk

setting {
namespace = "aws:autoscaling:trigger"
name      = "MeasureName"
value     = var.autoscale_measure_name
resource  = ""
}

setting {
namespace = "aws:autoscaling:trigger"
name      = "Statistic"
value     = var.autoscale_statistic
resource  = ""
}

setting {
namespace = "aws:autoscaling:trigger"
name      = "Unit"
value     = var.autoscale_unit
resource  = ""
}

setting {
namespace = "aws:autoscaling:trigger"
name      = "LowerThreshold"
value     = var.autoscale_lower_bound
resource  = ""
}

setting {
namespace = "aws:autoscaling:trigger"
name      = "LowerBreachScaleIncrement"
value     = var.autoscale_lower_increment
resource  = ""
}

setting {
namespace = "aws:autoscaling:trigger"
name      = "UpperThreshold"
value     = var.autoscale_upper_bound
resource  = ""
}

setting {
namespace = "aws:autoscaling:trigger"
name      = "UpperBreachScaleIncrement"
value     = var.autoscale_upper_increment
resource  = ""
}
setting {
namespace = "aws:elasticbeanstalk:environment:proxy"
name      = "ProxyServer"
value     = "apache"
}

setting {
namespace = "aws:elasticbeanstalk:container:php:phpini"
name      = "document_root"
value     = var.document_root
}
setting {
namespace = "aws:elasticbeanstalk:container:php:phpini"
name      = "memory_limit"
value     = var.memory_limit
}
setting {
namespace = "aws:elasticbeanstalk:container:php:phpini"
name      = "max_execution_time"
value     = var.max_execution_time
}
// Will enable it once approved by security
//  lifecycle {
//    ignore_changes = [
//      setting,
//    ]
//  }

tags = {
"stack"     = var.stack
"stack_env" = var.environment
"application" = var.application
}
}
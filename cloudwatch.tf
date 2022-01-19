
# BEGIN: CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "dashboard" {
  count          = length(var.environment)
  dashboard_name = "${var.stack}-${var.environment[count.index]}"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "y": 0,
            "x": 0,
            "width": 8,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ { "expression": "SEARCH(' \"LoadAverage1min\" ', 'Average', 300)", "label": "Expression1", "id": "e1" } ]
                ],
                "region": "${var.region_primary}",
                "title": "EC2 LoadAverage1min ${aws_elastic_beanstalk_environment.environment[count.index].name}"
            }
        },
        {
            "type": "metric",
            "y": 0,
            "x": 8,
            "width": 8,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ { "expression": "SEARCH(' \"MemoryUtilization\" ', 'Average', 300)", "label": "Expression1", "id": "e1" } ]
                ],
                "region": "${var.region_primary}",
                "title": "EC2 MemoryUtilization (%) ${aws_elastic_beanstalk_environment.environment[count.index].name}"
            }
        },
        {
            "type": "metric",
            "y": 6,
            "x": 0,
            "width": 8,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${aws_alb.application_load_balancer.name}" ]
                ],
                "region": "${var.region_primary}",
                "title": "ELB (Load Balancer) RequestCount"
            }
        },
         {
            "type": "metric",
            "y": 0,
            "x": 16,
            "width": 8,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/RDS", "DatabaseConnections", "DBClusterIdentifier", "${aws_db_instance.this.address}" ]
                ],
                "region": "${var.region_primary}",
                "title": "RDS DatabaseConnections ${aws_db_instance.this.address}"
            }
        },
        {
            "type": "metric",
            "y": 6,
            "x": 8,
            "width": 8,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${aws_alb.application_load_balancer.name}" ]
                ],
                "region": "${var.region_primary}",
                "title": "ELB (Load Balancer) TargetResponseTime"
            }
        },
        {
            "type": "metric",
            "y": 6,
            "x": 16,
            "width": 8,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_ELB_504_Count", "LoadBalancer", "${aws_alb.application_load_balancer.name}" ],
                    [ ".", "HTTPCode_ELB_502_Count", ".", "." ]
                ],
                "region": "${var.region_primary}",
                "title": "ELB (Load Balancer) 504 count"
            }
        },
         {
            "type": "metric",
            "y": 12,
            "x": 0,
            "width": 8,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ElasticBeanstalk", "ApplicationRequestsTotal", "EnvironmentName", "${aws_elastic_beanstalk_environment.environment[count.index].name}" ]
                ],
                "region": "${var.region_primary}",
                "title": "ElasticBeanstalk ApplicationRequestsTotal ${aws_elastic_beanstalk_environment.environment[count.index].name}"
            }
        },
        {
            "type": "metric",
            "y": 12,
            "x": 8,
            "width": 8,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ElasticBeanstalk", "ApplicationLatencyP99.9", "EnvironmentName", "${aws_elastic_beanstalk_environment.environment[count.index].name}" ]
                ],
                "region": "${var.region_primary}",
                "title": "ElasticBeanstalk ApplicationLatencyP99.9 ${aws_elastic_beanstalk_environment.environment[count.index].name}"
            }
        },
           {
            "type": "metric",
            "y": 12,
            "x": 16,
            "width": 8,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ElasticBeanstalk", "ApplicationRequests4xx", "EnvironmentName", "${aws_elastic_beanstalk_environment.environment[count.index].name}" ],
                    [ ".", "ApplicationRequests5xx", ".", "." ]
                ],
                "region": "${var.region_primary}",
                "title": "ElasticBeanstalk ApplicationRequests4xx/5xx ${aws_elastic_beanstalk_environment.environment[count.index].name}"
            }
        }
    ]
}
EOF
}


# RDS alarm
resource "aws_cloudwatch_metric_alarm" "rdsfreeablememory" {
  count               = length(var.environment)
  alarm_name          = "${var.stack}-${var.environment[count.index]}-rds-FreeableMemory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "100000000"

  dimensions = {
    DBClusterIdentifier = aws_db_instance.this.address
  }

  alarm_description = "Alerts if the RDS FreeableMemory goes below 100M for at least 15 minutes"
  alarm_actions     = [aws_sns_topic.topic.arn]
  ok_actions        = [aws_sns_topic.topic.arn]

  lifecycle {
    create_before_destroy = true
  }
}

# RDS alarm
resource "aws_cloudwatch_metric_alarm" "databaseconnections" {
  count               = length(var.environment)
  alarm_name          = "${var.stack}-${var.environment[count.index]}-rds-DatabaseConnections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "40"

  dimensions = {
    DBClusterIdentifier = aws_db_instance.this.address
  }

  alarm_description = "Alerts if the RDS DB connection count exceeds 40 for at least 3 minutes"
  alarm_actions     = [aws_sns_topic.topic.arn]
  ok_actions        = [aws_sns_topic.topic.arn]

  lifecycle {
    create_before_destroy = true
  }
}


# RDS alarm
resource "aws_cloudwatch_metric_alarm" "deadlocks" {
  count               = length(var.environment)
  alarm_name          = "${var.stack}-${var.environment[count.index]}-rds-Deadlocks"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "Deadlocks"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"

  dimensions = {
    DBClusterIdentifier = aws_db_instance.this.address
  }

  alarm_description = "Alerts if there are any RDS Deadlocks for at least 5 minutes"
  alarm_actions     = [aws_sns_topic.topic.arn]
  ok_actions        = [aws_sns_topic.topic.arn]

  lifecycle {
    create_before_destroy = true
  }
}

# RDS alarm
resource "aws_cloudwatch_metric_alarm" "cpuutilization" {
  count               = length(var.environment)
  alarm_name          = "${var.stack}-${var.environment[count.index]}-rds-CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "10"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "90"

  dimensions = {
    DBClusterIdentifier = aws_db_instance.this.address
  }

  alarm_description = "Alerts if RDS CPUUtilization is higher than 90% for at least 10 minutes"
  alarm_actions     = [aws_sns_topic.topic.arn]
  ok_actions        = [aws_sns_topic.topic.arn]

  lifecycle {
    create_before_destroy = true
  }
}

# END: CloudWatch Alarms


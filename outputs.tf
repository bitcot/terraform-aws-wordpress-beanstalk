output "beanstalk_url" {
  value       = aws_elastic_beanstalk_environment.environment.cname
}

output "alb_dns" {
  value       = aws_elastic_beanstalk_environment.environment.load_balancers
}

output "rds_endpoint" {
  value       = aws_db_instance.this.endpoint
}


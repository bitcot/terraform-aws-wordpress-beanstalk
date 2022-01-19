output "loadbalancer_url" {
    value = aws_alb.application_load_balancer.dns_name
}

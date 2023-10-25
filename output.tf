output "alb_link" {
  value = aws_lb.prom.dns_name
}
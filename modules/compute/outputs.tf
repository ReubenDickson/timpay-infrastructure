output "alb_dns_name" {
  description = "The URL James will use to access the app"
  value       = aws_lb.main_alb.dns_name
}
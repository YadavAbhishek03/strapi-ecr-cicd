output "strapi_url" {
  value = "http://${aws_lb.alb.dns_name}/admin"
  description = "Public URL to access Strapi"
}

output "blue_target_group_arn" {
  value = aws_lb_target_group.blue.arn
}

output "green_target_group_arn" {
  value = aws_lb_target_group.green.arn
}
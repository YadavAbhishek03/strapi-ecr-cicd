output "strapi_url" {
  value = "http://${aws_lb.alb.dns_name}/admin"
  description = "Public URL to access Strapi"
}

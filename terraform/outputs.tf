output "instance_public_ip" {
  value = aws_instance.strapi.public_ip
}

output "ssh_command" {
  value = "/home/surya/devops-terraform-project/terraform/ssh-key/strapi-key ubuntu@${aws_instance.strapi.public_ip}"
}

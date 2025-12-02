output "nginx_ingress_load_balancer_hostname" {
  description = "Hostname of the NGINX Ingress Load Balancer created by Helm"
  value       = data.aws_lb.nginx_ingress.dns_name
}

output "nginx_lb_ip" {
  description = "Load balancer IP (optional, often empty for AWS LBs)"
  value       = data.aws_lb.nginx_ingress.ip_address_type == "ipv4" ? data.aws_lb.nginx_ingress.dns_name : ""
}

output "nginx_ingress_lb_dns" {
  description = "DNS name of the NGINX ingress LB"
  value       = data.aws_lb.nginx_ingress.dns_name
}

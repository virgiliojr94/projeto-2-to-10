# Definir as variáveis do Terraform
variable "zone_name" {
  description = "The name of the DNS zone"
  default     = "kubernetes-zone"
}

variable "domain_name" {
  description = "The domain name for the application"
  default     = "example.com."
}

variable "subdomain_name" {
  description = "The subdomain name for the application"
  default     = "app"
}

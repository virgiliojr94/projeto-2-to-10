# Criar uma VPC
resource "google_compute_network" "vpc" {
  name                    = "kubernetes-vpc"
  auto_create_subnetworks = false
}

# Criar uma sub-rede
resource "google_compute_subnetwork" "subnet" {
  name          = "kubernetes-subnet"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.vpc.id
}

# Criar uma regra de firewall
resource "google_compute_firewall" "firewall" {
  name    = "kubernetes-firewall"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Criar um cluster Kubernetes
resource "google_container_cluster" "cluster" {
  name               = "kubernetes-cluster"
  location           = google_compute_subnetwork.subnet.region
  initial_node_count = 3

  node_config {
    machine_type    = "n1-standard-1"
    service_account = google_service_account.cluster.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    metadata        = { disable-legacy-endpoints = true }
    tags            = ["kubernetes-node"]
  }

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

}

# Criar uma conta de serviço para o cluster Kubernetes
resource "google_service_account" "cluster" {
  account_id   = "kubernetes-cluster-sa"
  display_name = "Kubernetes Cluster Service Account"
}

# Criar um balanceador de carga
resource "google_compute_address" "address" {
  name   = "kubernetes-address"
  region = google_compute_subnetwork.subnet.region
}

# Criar um health check HTTP para o Kubernetes
resource "google_compute_http_health_check" "health_check" {
  name               = "kubernetes-health-check"
  request_path       = "/"
  port               = 80
  check_interval_sec = 5
}

# Criar um serviço de backend para o Kubernetes
resource "google_compute_backend_service" "backend_service" {
  name          = "kubernetes-backend-service"
  port_name     = "http"
  protocol      = "HTTP"
  timeout_sec   = 10
  health_checks = [google_compute_http_health_check.health_check.id]
}

# Criar um mapeamento de URL para o Kubernetes
resource "google_compute_url_map" "url_map" {
  name            = "kubernetes-url-map"
  default_service = google_compute_backend_service.backend_service.id
}

# Criar um proxy HTTP para o Kubernetes
resource "google_compute_target_http_proxy" "proxy" {
  name    = "kubernetes-proxy"
  url_map = google_compute_url_map.url_map.id
}

# Criar uma regra de encaminhamento global para o Kubernetes
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "kubernetes-forwarding-rule"
  target     = google_compute_target_http_proxy.proxy.id
  port_range = "80"
  ip_address = google_compute_address.address.address
}

# Criar um registro DNS
resource "google_dns_managed_zone" "zone" {
  name     = var.zone_name
  dns_name = var.domain_name
}

#Cria um conjunto de registros DNS
resource "google_dns_record_set" "record_set" {
  managed_zone = google_dns_managed_zone.zone.name
  name         = "${var.subdomain_name}.${var.domain_name}"
  type         = "A"
  ttl          = "300"

  rrdatas = [google_compute_global_forwarding_rule.forwarding_rule.ip_address]
}

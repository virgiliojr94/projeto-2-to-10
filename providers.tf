terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "google" {
  project = "fluent-aileron-402020"
  region  = "us-central1"
}

provider "kubernetes" {
  # Configuration options
}

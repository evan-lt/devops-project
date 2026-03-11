terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
  required_version = ">= 1.6.0"
}

# ── Provider: point to local minikube ────────────────────────────────────────
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

# ── Variables ────────────────────────────────────────────────────────────────
variable "app_image" {
  description = "Docker image for the app"
  type        = string
  default     = "evanltx/devops-demo:latest"
}

variable "replicas" {
  description = "Number of pod replicas"
  type        = number
  default     = 2
}

# ── Namespace ────────────────────────────────────────────────────────────────
resource "kubernetes_namespace" "devops_project" {
  metadata {
    name = "devops-project"
    labels = {
      managed_by = "terraform"
      project    = "devops-demo"
    }
  }
}

# ── Deployment ───────────────────────────────────────────────────────────────
resource "kubernetes_deployment" "devops_demo" {
  metadata {
    name      = "devops-demo"
    namespace = kubernetes_namespace.devops_project.metadata[0].name
    labels = {
      app = "devops-demo"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "devops-demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "devops-demo"
        }
      }

      spec {
        container {
          name  = "devops-demo"
          image = var.app_image

          port {
            container_port = 5000
          }

          env {
            name  = "APP_ENV"
            value = "production"
          }

          resources {
            requests = {
              memory = "64Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "128Mi"
              cpu    = "250m"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 10
            period_seconds        = 15
          }
        }
      }
    }
  }
}

# ── Service ───────────────────────────────────────────────────────────────────
resource "kubernetes_service" "devops_demo" {
  metadata {
    name      = "devops-demo-service"
    namespace = kubernetes_namespace.devops_project.metadata[0].name
  }

  spec {
    selector = {
      app = "devops-demo"
    }

    port {
      port        = 80
      target_port = 5000
    }

    type = "NodePort"
  }
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "namespace" {
  value = kubernetes_namespace.devops_project.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.devops_demo.metadata[0].name
}

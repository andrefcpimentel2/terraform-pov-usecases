# provider "kubernetes" {
#   host = azurerm_kubernetes_cluster.k8s.kube_config.0.host

#   client_certificate     = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)}"
#   client_key             = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)}"
#   cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)}"
#   # username = azurerm_kubernetes_cluster.k8s.kube_config.0.username
#   # password = azurerm_kubernetes_cluster.k8s.kube_config.0.password
# }
# resource "kubernetes_service" "nginx_service" {
#   metadata {
#     name = "terraform-aks-nginx-service"
#   }
#   spec {
#     selector = {
#       app = "${kubernetes_pod.nginx_pod.metadata.0.labels.app}"
#     }
#     session_affinity = "ClientIP"
#     port {
#       port        = 8080
#       target_port = 80
#     }

#     type = "LoadBalancer"
#   }
# }

# resource "kubernetes_pod" "nginx_pod" {
#   metadata {
#     name = "terraform-aks-nginx-pod"
#     labels = {
#       app = "TerraformAKSNginx"
#     }
#   }

#   spec {
#     container {
#       image = "nginx:1.7.9"
#       name  = "nginx"
#     }
#   }
# }

# output "lb_ip" {
#   value = kubernetes_service.nginx_service.load_balancer_ingress[0].ip
# }
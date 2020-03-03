provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "k8s" {
    name     = var.resource_group_name
    location = var.location
}

resource "azurerm_network_security_group" "aks_sg" {
  name                = "aks_sg"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
}

resource "azurerm_network_security_rule" "outbound" {
  name                        = "aks-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.k8s.name
  network_security_group_name = azurerm_network_security_group.aks_sg.name
}

resource "azurerm_network_security_rule" "httpRule" {
  name                        = "HTTP"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.k8s.name}"
  network_security_group_name = "${azurerm_network_security_group.aks_sg.name}"
}

resource "azurerm_network_security_rule" "httpsRule" {
  name                        = "HTTPS"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.k8s.name}"
  network_security_group_name = "${azurerm_network_security_group.aks_sg.name}"
}

resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "test" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = var.log_analytics_workspace_location
    resource_group_name = azurerm_resource_group.k8s.name
    sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "test" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.test.location
    resource_group_name   = azurerm_resource_group.k8s.name
    workspace_resource_id = azurerm_log_analytics_workspace.test.id
    workspace_name        = azurerm_log_analytics_workspace.test.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = var.cluster_name
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name
    dns_prefix          = var.dns_prefix

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
        name            = "agentpool"
        node_count      = var.agent_count
        vm_size         = "Standard_DS1_v2"
    }

    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

    addon_profile {
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
        }
        kube_dashboard {
            enabled = true
        }
    }

    tags = {
        Environment = "Development"
    }
}

# Initialize Helm (and install Tiller)
provider "helm" {
  install_tiller = true

  kubernetes {
    host                   = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"
    client_certificate     = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)}"
  }
}

# Create Static Public IP Address to be used by Nginx Ingress
resource "azurerm_public_ip" "nginx_ingress" {
  name                = "nginx_ingress-ip"
    location            = "WestEurope"
    resource_group_name = azurerm_resource_group.k8s.name
    allocation_method   = "Static"
    domain_name_label   = var.dns_prefix
 
    depends_on = [ "azurerm_kubernetes_cluster.k8s" ]
}

# Add Kubernetes Stable Helm charts repo
resource "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "nginx_ingress" {
 
     name       = "nginx-ingress"
     repository =  helm_repository.stable.metadata.0.name
     chart      = "nginx-ingress"
     timeout    = 2400
 
     set {
         name  = "controller.replicaCount"
         value = "1"
     }
     set {
         name  = "controller.service.loadBalancerIP"
         value = "${azurerm_public_ip.nginx_ingress.ip_address}"
     }
     set_string {
         name  = "service.beta.kubernetes.io/azure-load-balancer-resource-group"
         value = "${azurerm_resource_group.k8s.name}"
     }
 
    depends_on = [ "azurerm_public_ip.nginx_ingress" ]
}
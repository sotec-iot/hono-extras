locals {
  values = [yamlencode(
    {
      controller = {
        replicaCount = var.advanced_load_balancer.replicaCount
        resources = var.advanced_load_balancer.resources
        service = {
          tcpPorts = [
            for port_config in var.advanced_load_balancer.port_configs :
            port_config
          ]
          type: "LoadBalancer"
          enablePorts = {
            http: false
            https: false
            stat: false
            prometheus: false
          }
          loadBalancerIP = var.mqtt_static_ip
        }
        extraArgs = [
          "--configmap-tcp-services=${var.hono_namespace}/${kubernetes_config_map.tcp.metadata[0].name}"
        ]
        nodeSelector = {
          "cloud.google.com/compute-class": "Balanced"
          "supported-cpu-platform.cloud.google.com/Intel_Cascade_Lake": "true"
        }
        PodDisruptionBudget = {
          enable: true
          minAvailable: 2
        }
      }
    }
  )]
}

resource "kubernetes_config_map" "tcp" {
  metadata {
    name = "tcp"
    namespace = var.hono_namespace
  }
  data = {
    for key, value in var.advanced_load_balancer.tcp_configmap_data :
    key => value
  }
}

resource "helm_release" "load-balancer" {
  name             = "haproxy"
  repository       = "https://haproxytech.github.io/helm-charts"
  chart            = "kubernetes-ingress"
  version          = var.advanced_load_balancer.chart_version
  namespace        = var.hono_namespace
  create_namespace = false
  timeout          = 120

  # using yaml to set values in the helm chart
  values = local.values
}

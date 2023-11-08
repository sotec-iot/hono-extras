locals {
  values = [yamlencode(
    {
      controller = {
        replicaCount = var.enhanced_mqtt_load_balancer.replicaCount
        service = {
          tcpPorts = [
            for port_config in var.enhanced_mqtt_load_balancer.port_configs :
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
    for key, value in var.enhanced_mqtt_load_balancer.tcp_configmap_data :
    key => value
  }
}

resource "helm_release" "load-balancer" {
  name             = "haproxy"
  repository       = "https://haproxytech.github.io/helm-charts"
  chart            = "kubernetes-ingress"
  version          = var.enhanced_mqtt_load_balancer.chart_version
  namespace        = var.hono_namespace
  create_namespace = false
  timeout          = 120

  # using yaml to set values in the helm chart
  values = local.values
}

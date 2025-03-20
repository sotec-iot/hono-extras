locals {
  common_load_balancer_values = {
    controller = {
      replicaCount = var.advanced_load_balancer.replicaCount
      resources    = var.advanced_load_balancer.resources
      service = {
        tcpPorts = [
          for port_config in var.advanced_load_balancer.port_configs :
          port_config
        ]
        type = "LoadBalancer"
        enablePorts = {
          http       = false
          https      = false
          stat       = false
          prometheus = false
        }
        loadBalancerIP = var.mqtt_static_ip
      }
      extraArgs = [
        "--configmap-tcp-services=${var.hono_namespace}/${kubernetes_config_map.tcp.metadata[0].name}"
      ]
      PodDisruptionBudget = {
        enable       = true
        minAvailable = 2
      }
    }
  }

  # values for the standard GKE cluster
  values = [yamlencode(local.common_load_balancer_values)]

  # values for the GKE autopilot cluster
  values_autopilot = [yamlencode(
    merge(
      local.common_load_balancer_values,
      {
        controller = {
          nodeSelector = {
            "cloud.google.com/compute-class"                             = "Balanced"
            "supported-cpu-platform.cloud.google.com/Intel_Cascade_Lake" = "true"
          }
        }
      }
    )
  )]
}
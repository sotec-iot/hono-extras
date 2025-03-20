resource "kubernetes_config_map" "tcp" {
  metadata {
    name      = "tcp"
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
  values = var.gke_autopilot_enabled ? local.values_autopilot : local.values

}

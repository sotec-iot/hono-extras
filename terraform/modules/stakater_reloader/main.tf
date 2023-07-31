resource "helm_release" "stakater-reloader" {
  name             = "stakater"
  repository       = "https://stakater.github.io/stakater-charts"
  chart            = "reloader"
  version          = var.reloader_version
  namespace        = var.hono_namespace
  create_namespace = false

  set {
    name  = "reloader.watchGlobally"
    value = "false"
  }
}

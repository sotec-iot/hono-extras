resource "kubernetes_namespace" "hono" {
  metadata {
    name = var.hono_namespace
  }

}

resource "kubernetes_namespace" "cert-manager" {
  count = var.enable_cert_manager ? 1 : 0
  metadata {
    name = var.cert_manager_namespace
  }
}
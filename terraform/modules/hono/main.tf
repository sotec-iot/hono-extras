locals {
  # creating the configuration to connect to the SQL Database
  db_connection_config = {
    # build the URL for the connection
    url         = "jdbc:postgresql://${var.sql_ip}:5432/${var.sql_database}"
    driverClass = "org.postgresql.Driver"
    username    = var.sql_user
    password    = var.sql_db_pw
  }

  # creation of database block to use in the resource call
  database_block = {
    jdbc = {
      adapter    = local.db_connection_config
      management = local.db_connection_config
    }
  }

  values = [jsonencode(
    {
      googleProjectId = var.project_id
      adapters = {
        http = {
          enabled = var.enable_http_adapter
          svc = {
            loadBalancerIP = var.http_static_ip # sets a static IP loadbalancerIP for http adapter
          }
          tlsKeysSecret = var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name
        }
        mqtt = {
          enabled = var.enable_mqtt_adapter
          svc = {
            loadBalancerIP = var.mqtt_static_ip # sets a static IP loadbalancerIP for mqtt adapter
          }
          tlsKeysSecret = var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name
        }
      }
      deviceRegistryExample = {
        # sets database connection config
        jdbcBasedDeviceRegistry = {
          tenant   = local.database_block
          registry = local.database_block
        }
      }
      deviceCommunication = {
        app = {
          name = var.oauth_app_name
        }
        api = {
          database = { # database connection for device Communication
            name     = var.sql_database
            host     = var.sql_ip
            port     = 5432
            username = var.sql_user
            password = var.sql_db_pw
          }
        }
      }
      cloudEndpoints = {
        esp = {
          serviceName = var.service_name_communication
        }
      }
      externalIngress = {
        ingressTlsSecret  = var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name
        staticIpName      = var.device_communication_static_ip_name
        host              = var.device_communication_dns_name
      }
      managementUi = {
        googleClientId = var.oauth_client_id
      }
    }
  )]
}

resource "kubernetes_namespace" "hono" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "hono_domain_secret_tls" {
  count = !var.cert_manager_enabled && ((var.hono_tls_key != null && var.hono_tls_crt != null) || (var.hono_tls_key_from_storage != null && var.hono_tls_crt_from_storage != null)) ? 1 : 0
  metadata {
    name      = var.hono_domain_secret_name
    namespace = kubernetes_namespace.hono.metadata[0].name
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = var.hono_tls_crt == null ? var.hono_tls_crt_from_storage : var.hono_tls_crt
    "tls.key" = var.hono_tls_key == null ? var.hono_tls_key_from_storage : var.hono_tls_key
  }
}

resource "kubernetes_secret" "cloud_endpoints_key_file" {
  metadata {
    name      = "service-account-creds"
    namespace = kubernetes_namespace.hono.metadata[0].name
  }
  binary_data = {
    "hono-cloud-endpoint-manager.json" = var.cloud_endpoints_key_file
  }
}

resource "kubernetes_secret" "iap_client_secret" {
  metadata {
    name = "iap-client-secret"
    namespace = kubernetes_namespace.hono.metadata[0].name
  }
  data = {
    "client_id"     = var.oauth_client_id
    "client_secret" = var.oauth_client_secret
  }
}

resource "helm_release" "hono" {
  name             = "eclipse-hono"
  repository       = var.helm_package_repository # Repository of the hono package
  chart            = var.hono_chart_name         # name of the chart in the repository
  version          = var.hono_chart_version      # version of the chart in the repository
  namespace        = kubernetes_namespace.hono.metadata[0].name
  create_namespace = false
  timeout          = 600

  # using json to set values in the helm chart
  values = local.values
}

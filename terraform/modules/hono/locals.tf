locals {
  # creating the configuration to connect to the SQL Database
  db_connection_config = {
    # build the URL for the connection
    url         = "jdbc:postgresql://${var.sql_ip}:5432/${var.sql_hono_database}"
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

  deployment = {
    annotations = {
      "reloader.stakater.com/auto" = "true"
    }
  }

  values = [
    jsonencode(
      {
        googleProjectId = var.project_id
        adapters = {
          http = {
            enabled = var.enable_http_adapter
            svc = {
              annotations    = var.legacy_load_balancer_setup_enabled ? {} : { "cloud.google.com/neg" = "{\"exposed_ports\": {\"443\": {\"name\": \"hono-http-adapter-neg\"}}}" }
              type           = var.legacy_load_balancer_setup_enabled ? "LoadBalancer" : "ClusterIP"
              loadBalancerIP = var.http_adapter_static_ip # sets a static IP loadbalancerIP for http adapter
            }
            deployment             = var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled ? local.deployment : {}
            tlsKeysSecret          = var.legacy_load_balancer_setup_enabled ? var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name : "example"
            tlsTrustStoreConfigMap = var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled ? var.hono_trust_store_config_map_name : "example"
          }
          mqtt = {
            enabled = var.enable_mqtt_adapter
            svc = {
              annotations    = var.legacy_load_balancer_setup_enabled ? {} : {"cloud.google.com/neg" = "{\"exposed_ports\": {\"8883\": {\"name\": \"hono-mqtt-adapter-neg\"}}}"}
              type           = var.legacy_load_balancer_setup_enabled ? "LoadBalancer" : "ClusterIP"
              loadBalancerIP = var.mqtt_adapter_static_ip # sets a static IP loadbalancerIP for mqtt adapter
            }
            deployment             = var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled ? local.deployment : {}
            tlsKeysSecret          = var.legacy_load_balancer_setup_enabled ? var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name : "example"
            tlsTrustStoreConfigMap = var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled ? var.hono_trust_store_config_map_name : "example"
            horizontalPodAutoscaler = {
              enabled     = var.hpa_enabled
              minReplicas = var.hpa_minReplicas_mqtt
              maxReplicas = var.hpa_maxReplicas_mqtt
              metrics     = var.hpa_metrics_mqtt
            }
          }
        }
        authServer = {
          deployment    = var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled ? local.deployment : {}
          tlsKeysSecret = var.legacy_load_balancer_setup_enabled ? var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name : "example"
        }
        deviceRegistryExample = {
          svc = {
            annotations    = var.legacy_load_balancer_setup_enabled ? {} : {"cloud.google.com/neg": "{\"exposed_ports\": {\"8443\":{\"name\": \"hono-device-registry-neg\"}}}"}
          }
          tlsKeysSecret          = var.legacy_load_balancer_setup_enabled ? var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name : "example"
          tlsTrustStoreConfigMap = var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled ? var.hono_trust_store_config_map_name : "example"
          # sets database connection config
          jdbcBasedDeviceRegistry = {
            deployment = var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled ? local.deployment : {}
            tenant     = local.database_block
            registry   = local.database_block
            horizontalPodAutoscaler = {
              enabled     = var.hpa_enabled
              minReplicas = var.hpa_minReplicas_device_registry
              maxReplicas = var.hpa_maxReplicas_device_registry
            }
          }
        }
        dataGridExample = {
          replicas = var.data_grid_replicas
        }
        commandRouterService = {
          deployment             = var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled ? local.deployment : {}
          tlsKeysSecret          = var.legacy_load_balancer_setup_enabled ? var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name : "example"
          tlsTrustStoreConfigMap = var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled ? var.hono_trust_store_config_map_name : "example"
        }
        grafana = {
          service = {
            annotations = !var.legacy_load_balancer_setup_enabled && var.grafana_expose_externally ? {"cloud.google.com/neg" = "{\"exposed_ports\": {\"3000\": {\"name\": \"hono-grafana-neg\"}}}"} : {}
          }
          ingress = {
            enabled = var.legacy_load_balancer_setup_enabled && var.grafana_expose_externally
            annotations = {
              "kubernetes.io/ingress.global-static-ip-name" = var.grafana_static_ip_name
            }
            hosts = [
              var.grafana_dns_name
            ]
            tls = [
              {
                secretName = var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name
              }
            ]
          }
          "grafana.ini" = {
            database = {
              type     = "postgres"
              host     = "${var.sql_ip}:5432"
              name     = var.sql_grafana_database
              user     = var.sql_user
              password = "${var.sql_db_pw}"
              ssl_mode = "disable"
            }
            server = !var.legacy_load_balancer_setup_enabled && var.grafana_expose_externally ? {
              root_url            = "%(protocol)s://%(domain)s:%(http_port)s/grafana/"
              serve_from_sub_path = true
            } : {}
          }
        }
        deviceCommunication = {
          app = {
            name = var.oauth_app_name
          }
          api = {
            database = {
              # database connection for device Communication
              name     = var.sql_hono_database
              host     = var.sql_ip
              port     = 5432
              username = var.sql_user
              password = var.sql_db_pw
            }
            svc = {
              annotations = var.legacy_load_balancer_setup_enabled ? {} : {"cloud.google.com/neg": "{\"exposed_ports\": {\"8080\":{\"name\": \"hono-device-communication-neg\"}}}"}
            }
          }
        }
        cloudEndpoints = {
          enabled = var.legacy_load_balancer_setup_enabled
          esp = {
            serviceName = var.service_name_communication
          }
        }
        externalIngress = {
          enabled          = var.legacy_load_balancer_setup_enabled
          ingressTlsSecret = var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name
          staticIpName     = var.hono_api_static_ip_name
          host             = var.hono_api_host_address
          sslPolicy        = element(split("/", var.ssl_policy), -1)
        }
        managementUi = {
          googleClientId = var.oauth_client_id
          svc = {
            annotations = var.legacy_load_balancer_setup_enabled ? {} : {"cloud.google.com/neg": "{\"exposed_ports\": {\"8080\":{\"name\": \"hono-device-management-ui-neg\"}}}"}
          }
        }
      }
    )
  ]

  # key is specified but not used, terraform needs a static key in for_each, and as a set uses its value as "key", these maps with dummy-values are necessary
  pubsub_editor_members = {
    "adapter"                      = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-adapter",
    "service-command-router"       = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-command-router",
    "service-device-registry"      = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-device-registry",
    "service-device-communication" = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-device-communication",
  }

  cloud_trace_agent_members = {
    "adapter"                      = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-adapter",
    "service-command-router"       = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-command-router",
    "service-device-registry"      = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-device-registry",
    "service-device-communication" = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-device-communication",
  }
}

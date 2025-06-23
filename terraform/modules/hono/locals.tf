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
              loadBalancerIP = var.http_static_ip # sets a static IP loadbalancerIP for http adapter
            }
            deployment             = local.deployment
            tlsKeysSecret          = var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name
            tlsTrustStoreConfigMap = var.cert_manager_enabled ? var.hono_trust_store_config_map_name : "example"
          }
          mqtt = {
            enabled = var.mqtt_adapter.enabled
            svc = {
              annotations = {
                "haproxy.org/load-balance" = var.mqtt_adapter.advanced_load_balancer.algorithm
              }
              type           = var.mqtt_adapter.advanced_load_balancer.enabled ? "ClusterIP" : "LoadBalancer"
              loadBalancerIP = var.mqtt_static_ip # sets a static IP loadbalancerIP for mqtt adapter
            }
            deployment             = local.deployment
            tlsKeysSecret          = var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name
            tlsTrustStoreConfigMap = var.cert_manager_enabled ? var.hono_trust_store_config_map_name : "example"
            horizontalPodAutoscaler = {
              enabled     = var.hpa_enabled
              minReplicas = var.hpa_minReplicas_mqtt
              maxReplicas = var.hpa_maxReplicas_mqtt
              metrics     = var.hpa_metrics_mqtt
            }
          }
        }
        authServer = {
          deployment    = local.deployment
          tlsKeysSecret = var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name
        }
        deviceRegistryExample = {
          tlsKeysSecret          = var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name
          tlsTrustStoreConfigMap = var.cert_manager_enabled ? var.hono_trust_store_config_map_name : "example"
          # sets database connection config
          jdbcBasedDeviceRegistry = {
            deployment = local.deployment
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
          deployment             = local.deployment
          tlsKeysSecret          = var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name
          tlsTrustStoreConfigMap = var.cert_manager_enabled ? var.hono_trust_store_config_map_name : "example"
        }
        grafana = {
          ingress = {
            enabled = var.grafana_expose_externally
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
          }
        }
        cloudEndpoints = {
          esp = {
            serviceName = var.service_name_communication
          }
        }
        externalIngress = {
          ingressTlsSecret = var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name
          staticIpName     = var.device_communication_static_ip_name
          host             = var.device_communication_dns_name
          sslPolicy        = var.ssl_policy_name
        }
        managementUi = {
          googleClientId = var.oauth_client_id
        }
      }
    )
  ]

  # key is specified but not used, terraform needs a static key in for_each, and as a set uses its value as "key", these maps with dummy-values are necessary
  service_account_user_members = {
    "adapter"                      = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-adapter",
    "service-command-router"       = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-command-router",
    "service-device-registry"      = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-device-registry",
    "service-device-communication" = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-device-communication",
  }

  project_token_creator_members = {
    "adapter"                      = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-adapter",
    "service-command-router"       = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-command-router",
    "service-device-registry"      = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-device-registry",
    "service-device-communication" = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-device-communication",
  }

  pubsub_editor_members = {
    "adapter"                      = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-adapter",
    "service-command-router"       = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-command-router",
    "service-device-registry"      = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-device-registry",
    "service-device-communication" = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-device-communication",
  }

  cloud_trace_agent_members = {
    "adapter"                 = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-adapter",
    "service-command-router"  = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-command-router",
    "service-device-registry" = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-service-device-registry",
  }
}

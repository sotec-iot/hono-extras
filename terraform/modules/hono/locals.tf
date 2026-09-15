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

  # effective values for the Grafana firebase proxy env vars, falling back to defaults derived from project and domain settings
  firebase_rtdb_url          = var.firebase_rtdb_url != null ? var.firebase_rtdb_url : "https://${var.project_id}-default-rtdb.europe-west1.firebasedatabase.app"
  app_login_url              = var.app_login_url != null ? var.app_login_url : "https://${trimprefix(var.hono_root_domain, "hono.")}/#/login"
  grafana_public_url         = var.grafana_public_url != null ? var.grafana_public_url : "https://${var.hono_root_domain}/grafana"
  cookie_signing_salt_secret = var.cookie_signing_salt_secret != null ? var.cookie_signing_salt_secret : "projects/${var.project_number}/secrets/scitis-cookie-salt/versions/latest"

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
            deployment             = var.cert_manager_enabled ? local.deployment : {}
            tlsKeysSecret          = var.legacy_load_balancer_setup_enabled ? (var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name) : (var.cert_manager_enabled ? var.hono_internal_tls_secret_name : "example")
            tlsTrustStoreConfigMap = var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled ? var.hono_trust_store_config_map_name : "example"
            singleCertSecret       = !var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled
          }
          mqtt = {
            enabled = var.enable_mqtt_adapter
            svc = {
              type           = "LoadBalancer"
              loadBalancerIP = var.mqtt_adapter_static_ip # sets a static IP loadbalancerIP for mqtt adapter
            }
            deployment             = var.cert_manager_enabled ? local.deployment : {}
            tlsKeysSecret          = var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name
            tlsTrustStoreConfigMap = var.cert_manager_enabled ? var.hono_trust_store_config_map_name : "example"
            singleCertSecret       = false
            horizontalPodAutoscaler = {
              enabled     = var.hpa_enabled
              minReplicas = var.hpa_minReplicas_mqtt
              maxReplicas = var.hpa_maxReplicas_mqtt
              metrics     = var.hpa_metrics_mqtt
            }
          }
        }
        authServer = {
          deployment    = var.cert_manager_enabled ? local.deployment : {}
          tlsKeysSecret = var.legacy_load_balancer_setup_enabled ? (var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name) : (var.cert_manager_enabled ? var.hono_internal_tls_secret_name : "example")
        }
        deviceRegistryExample = {
          svc = {
            annotations = var.legacy_load_balancer_setup_enabled ? {} : { "cloud.google.com/neg" : "{\"exposed_ports\": {\"8443\":{\"name\": \"hono-device-registry-neg\"}}}" }
          }
          tlsKeysSecret          = var.legacy_load_balancer_setup_enabled ? (var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name) : (var.cert_manager_enabled ? var.hono_internal_tls_secret_name : "example")
          tlsTrustStoreConfigMap = var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled ? var.hono_trust_store_config_map_name : "example"
          singleCertSecret       = !var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled
          # sets database connection config
          jdbcBasedDeviceRegistry = {
            deployment = var.cert_manager_enabled ? local.deployment : {}
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
          deployment             = var.cert_manager_enabled ? local.deployment : {}
          tlsKeysSecret          = var.legacy_load_balancer_setup_enabled ? (var.cert_manager_enabled ? var.hono_domain_managed_secret_name : var.hono_domain_secret_name) : (var.cert_manager_enabled ? var.hono_internal_tls_secret_name : "example")
          tlsTrustStoreConfigMap = var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled ? var.hono_trust_store_config_map_name : "example"
          singleCertSecret       = !var.legacy_load_balancer_setup_enabled && var.cert_manager_enabled
        }
        grafana = {
          extraContainers = <<-EOT
            - name: firebase-grafana-proxy
              image: gcr.io/sotec-iot-core-dev/grafana-proxy:${var.grafana_proxy_version}
              imagePullPolicy: IfNotPresent
              ports:
                - name: proxy-http
                  containerPort: 4181
                  protocol: TCP
              env:
                - name: FIREBASE_RTDB_URL
                  value: "${local.firebase_rtdb_url}"
                - name: TARGET_GRAFANA_URL
                  value: "http://127.0.0.1:3000"
                - name: APP_LOGIN_URL
                  value: "${local.app_login_url}"
                - name: GRAFANA_PUBLIC_URL
                  value: "${local.grafana_public_url}"
                - name: COOKIE_SIGNING_SALT_SECRET
                  value: "${local.cookie_signing_salt_secret}"
                - name: REVOKED_JTIS
                  value: ""
              readinessProbe:
                httpGet:
                  path: /readyz
                  port: 4181
                initialDelaySeconds: 5
                periodSeconds: 10
                tcpSocket: null
              livenessProbe:
                httpGet:
                  path: /livez
                  port: 4181
                initialDelaySeconds: 15
                periodSeconds: 20
                tcpSocket: null
              resources:
                requests:
                  cpu: 25m
                  memory: 64Mi
                limits:
                  memory: 256Mi
              securityContext:
                runAsNonRoot: true
                runAsUser: 65532
                runAsGroup: 65532
                allowPrivilegeEscalation: false
                readOnlyRootFilesystem: true
                capabilities:
                  drop: ["ALL"]
          EOT
          service = {
            annotations = !var.legacy_load_balancer_setup_enabled && var.grafana_expose_externally ? { "cloud.google.com/neg" = "{\"exposed_ports\": {\"3000\": {\"name\": \"grafana-neg\"}}}" } : {}
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
              root_url = "https://${var.grafana_dns_name}/"
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
              annotations = var.legacy_load_balancer_setup_enabled ? {} : { "cloud.google.com/neg" : "{\"exposed_ports\": {\"8080\":{\"name\": \"hono-device-communication-neg\"}}}" }
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
            annotations = var.legacy_load_balancer_setup_enabled ? {} : { "cloud.google.com/neg" : "{\"exposed_ports\": {\"8080\":{\"name\": \"hono-device-management-ui-neg\"}}}" }
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

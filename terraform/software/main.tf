moved {
  from = module.hono.kubernetes_namespace.hono
  to   = module.namespace.kubernetes_namespace.hono
}

module "namespace" {
  source = "../modules/namespace"
  hono_namespace                      = var.hono_namespace
  cert_manager_namespace              = var.cert_manager_namespace
  enable_cert_manager                 = var.enable_cert_manager
}

module "hono" {
  source                              = "../modules/hono"
  hono_namespace                      = var.hono_namespace
  cluster_name                        = var.cluster_name
  project_id                          = var.project_id
  enable_http_adapter                 = var.enable_http_adapter
  enable_mqtt_adapter                 = var.enable_mqtt_adapter
  http_static_ip                      = var.http_static_ip
  mqtt_static_ip                      = var.mqtt_static_ip
  sql_user                            = var.sql_user
  sql_db_pw                           = var.sql_db_pw
  sql_database                        = var.sql_database
  sql_ip                              = var.sql_ip
  service_name_communication          = var.service_name_communication
  device_communication_static_ip_name = var.device_communication_static_ip_name
  helm_package_repository             = var.helm_package_repository
  hono_chart_name                     = var.hono_chart_name
  hono_chart_version                  = var.hono_chart_version
  oauth_app_name                      = var.oauth_app_name
  device_communication_dns_name       = var.device_communication_dns_name
  hono_tls_key                        = var.hono_tls_key
  hono_tls_crt                        = var.hono_tls_crt
  hono_tls_key_from_storage           = var.hono_tls_key_from_storage
  hono_tls_crt_from_storage           = var.hono_tls_crt_from_storage
  cloud_endpoints_key_file            = var.cloud_endpoints_key_file
  hono_domain_secret_name             = var.hono_domain_secret_name
  hono_domain_managed_secret_name     = var.hono_domain_managed_secret_name
  hono_trust_store_config_map_name    = var.hono_trust_store_config_map_name
  oauth_client_id                     = var.oauth_client_id
  oauth_client_secret                 = var.oauth_client_secret
  cert_manager_enabled                = var.enable_cert_manager
  ssl_policy_name                     = var.ssl_policy_name

  depends_on = [module.namespace, module.cert-manager]
}

module "cert-manager" {
  source                              = "../modules/cert_manager"
  count                               = var.enable_cert_manager ? 1 : 0
  hono_namespace                      = var.hono_namespace
  cert_manager_namespace              = var.cert_manager_namespace
  cert_manager_version                = var.cert_manager_version
  cert_manager_issuer_kind            = var.cert_manager_issuer_kind
  cert_manager_issuer_name            = var.cert_manager_issuer_name
  cert_manager_issuer_project_id      = var.cert_manager_issuer_project_id
  cert_manager_email                  = var.cert_manager_email
  cert_manager_sa_account_id          = var.cert_manager_sa_account_id
  cert_manager_sa_key_file            = var.cert_manager_sa_key_file
  cert_manager_cert_duration          = var.cert_manager_cert_duration
  cert_manager_cert_renew_before      = var.cert_manager_cert_renew_before
  hono_domain_managed_secret_name     = var.hono_domain_managed_secret_name
  wildcard_domain                     = var.wildcard_domain
  trust_manager_version               = var.trust_manager_version
  hono_trust_store_config_map_name    = var.hono_trust_store_config_map_name

  depends_on = [module.namespace]
}

module "stakater-reloader" {
  source                              = "../modules/stakater_reloader"
  count                               = var.enable_cert_manager ? 1 : 0
  hono_namespace                      = var.hono_namespace
  reloader_version                    = var.reloader_version
  depends_on = [module.namespace]
}

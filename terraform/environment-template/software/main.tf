module "software" {
  source = "../../software"

  project_id                          = data.terraform_remote_state.infrastructure.outputs.project_id
  http_adapter_static_ip              = try(data.terraform_remote_state.infrastructure.outputs.http_adapter_static_ip[0], "")
  mqtt_adapter_static_ip              = try(data.terraform_remote_state.infrastructure.outputs.mqtt_adapter_static_ip[0], "")
  sql_user                            = data.terraform_remote_state.infrastructure.outputs.sql_user
  sql_db_pw                           = data.terraform_remote_state.infrastructure.outputs.sql_db_pw
  sql_ip                              = data.terraform_remote_state.infrastructure.outputs.sql_ip
  sql_hono_database                   = data.terraform_remote_state.infrastructure.outputs.sql_hono_database
  sql_grafana_database                = data.terraform_remote_state.infrastructure.outputs.sql_grafana_database
  service_name_communication          = try(data.terraform_remote_state.infrastructure.outputs.service_name_communication, "")
  hono_api_static_ip_name             = data.terraform_remote_state.infrastructure.outputs.hono_api_static_ip_name
  hono_api_static_ip                  = data.terraform_remote_state.infrastructure.outputs.hono_api_static_ip
  grafana_static_ip_name              = try(data.terraform_remote_state.infrastructure.outputs.grafana_static_ip_name[0], "")
  grafana_expose_externally           = data.terraform_remote_state.infrastructure.outputs.grafana_expose_externally
  ssl_policy                          = data.terraform_remote_state.infrastructure.outputs.ssl_policy
  gke_autopilot_enabled               = try(data.terraform_remote_state.infrastructure.outputs.gke_autopilot_enabled, false)
  node_locations                      = data.terraform_remote_state.infrastructure.outputs.node_locations
  legacy_load_balancer_setup_enabled  = data.terraform_remote_state.infrastructure.outputs.legacy_load_balancer_setup_enabled
  hono_tls_key_from_storage           = try(data.terraform_remote_state.software.outputs.hono_tls_key_in_storage, null)
  hono_tls_crt_from_storage           = try(data.terraform_remote_state.software.outputs.hono_tls_crt_in_storage, null)
  hono_tls_key                        = try(file("${path.module}/hono_tls.key"), null)
  hono_tls_crt                        = try(file("${path.module}/hono_tls.crt"), null)
  oauth_app_name                      = local.oauth_app_name
  helm_package_repository             = local.helm_package_repository
  hono_chart_name                     = local.hono_chart_name
  hono_chart_version                  = local.hono_chart_version
  hono_api_host_address               = local.hono_api_host_address
  oauth_client_id                     = local.oauth_client_id
  oauth_client_secret                 = local.oauth_client_secret
  hono_root_domain                    = local.hono_root_domain
  enable_cert_manager                 = local.enable_cert_manager
  cert_manager_email                  = local.cert_manager_email
}

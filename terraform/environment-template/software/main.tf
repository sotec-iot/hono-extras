module "software" {
  source = "../../software"

  project_id                          = data.terraform_remote_state.infrastructure.outputs.project_id
  cluster_name                        = data.terraform_remote_state.infrastructure.outputs.cluster_name
  http_static_ip                      = try(data.terraform_remote_state.infrastructure.outputs.http_static_ip[0], "")
  mqtt_static_ip                      = try(data.terraform_remote_state.infrastructure.outputs.mqtt_static_ip[0], "")
  sql_user                            = data.terraform_remote_state.infrastructure.outputs.sql_user
  sql_db_pw                           = data.terraform_remote_state.infrastructure.outputs.sql_db_pw
  sql_ip                              = data.terraform_remote_state.infrastructure.outputs.sql_ip
  sql_database                        = data.terraform_remote_state.infrastructure.outputs.sql_database
  service_name_communication          = data.terraform_remote_state.infrastructure.outputs.service_name_communication
  device_communication_static_ip_name = data.terraform_remote_state.infrastructure.outputs.device_communication_static_ip_name
  ssl_policy_name                     = data.terraform_remote_state.infrastructure.outputs.ssl_policy_name
  cloud_endpoints_key_file            = data.terraform_remote_state.infrastructure.outputs.cloud_endpoints_key_file
  cert_manager_sa_account_id          = try(data.terraform_remote_state.infrastructure.outputs.cert_manager_sa_account_id[0], "")
  cert_manager_sa_key_file            = try(data.terraform_remote_state.infrastructure.outputs.cert_manager_sa_key_file[0], "")
  cert_manager_issuer_project_id      = try(data.terraform_remote_state.infrastructure.outputs.cert_manager_issuer_project_id[0], "")
  hono_tls_key_from_storage           = try(data.terraform_remote_state.software.outputs.hono_tls_key_in_storage, null)
  hono_tls_crt_from_storage           = try(data.terraform_remote_state.software.outputs.hono_tls_crt_in_storage, null)
  hono_tls_key                        = try(file("${path.module}/hono_tls.key"), null)
  hono_tls_crt                        = try(file("${path.module}/hono_tls.crt"), null)
  oauth_app_name                      = local.oauth_app_name
  helm_package_repository             = local.helm_package_repository
  hono_chart_name                     = local.hono_chart_name
  device_communication_dns_name       = local.device_communication_dns_name
  oauth_client_id                     = local.oauth_client_id
  oauth_client_secret                 = local.oauth_client_secret
  enable_cert_manager                 = local.enable_cert_manager
  cert_manager_email                  = local.cert_manager_email
  wildcard_domain                     = local.wildcard_domain
}

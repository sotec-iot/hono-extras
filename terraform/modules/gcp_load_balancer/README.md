## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_certificate_manager_certificate.hono_cert](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate) | resource |
| [google_certificate_manager_certificate.hono_wildcard_cert](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate) | resource |
| [google_certificate_manager_certificate_map.hono_cert_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map) | resource |
| [google_certificate_manager_certificate_map_entry.hono_adapter_cert_map_entry](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map_entry) | resource |
| [google_certificate_manager_certificate_map_entry.hono_cert_map_entry](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map_entry) | resource |
| [google_certificate_manager_dns_authorization.hono_dns_auth](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_dns_authorization) | resource |
| [google_compute_backend_service.device_communication_backend_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_backend_service.device_registry_backend_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_backend_service.grafana_backend_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_backend_service.http_adapter_backend_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_backend_service.management_ui_backend_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_backend_service.mqtt_adapter_backend_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_firewall.hbp_hono_https_lb_device_registry](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.mqtt_adapter_firewall_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_global_forwarding_rule.hono_api_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_global_forwarding_rule.http_adapter_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_global_forwarding_rule.mqtt_adapter_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_health_check.device_communication_heath_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_health_check.device_registry_heath_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_health_check.grafana_heath_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_health_check.http_adapter_heath_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_health_check.management_ui_heath_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_health_check.mqtt_adapter_health_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_security_policy.mqtt_adapter_security_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_security_policy) | resource |
| [google_compute_target_https_proxy.hono_api_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource |
| [google_compute_target_https_proxy.http_adapter_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource |
| [google_compute_target_ssl_proxy.mqtt_adapter_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_ssl_proxy) | resource |
| [google_compute_url_map.hono_api_loadbalancer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |
| [google_compute_url_map.http_adapter_loadbalancer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_available_zones"></a> [available\_zones](#input\_available\_zones) | Available node zone locations | `list(string)` | n/a | yes |
| <a name="input_enable_http_adapter"></a> [enable\_http\_adapter](#input\_enable\_http\_adapter) | Used to enable the http adapter | `bool` | n/a | yes |
| <a name="input_enable_mqtt_adapter"></a> [enable\_mqtt\_adapter](#input\_enable\_mqtt\_adapter) | Used to enable the mqtt adapter | `bool` | n/a | yes |
| <a name="input_gcp_load_balancer_log_config"></a> [gcp\_load\_balancer\_log\_config](#input\_gcp\_load\_balancer\_log\_config) | Logging configuration for the backend services of the GCP load balancers. | <pre>object({<br/>    ui = optional(object({<br/>      enable      = optional(bool)<br/>      sample_rate = optional(number)<br/>      optional_mode = optional(string)<br/>    }))<br/>    device_registry = optional(object({<br/>      enable      = optional(bool)<br/>      sample_rate = optional(number)<br/>      optional_mode = optional(string)<br/>    }))<br/>    device_communication = optional(object({<br/>      enable      = optional(bool)<br/>      sample_rate = optional(number)<br/>      optional_mode = optional(string)<br/>    }))<br/>    grafana = optional(object({<br/>      enable      = optional(bool)<br/>      sample_rate = optional(number)<br/>      optional_mode = optional(string)<br/>    }))<br/>    mqtt_adapter = optional(object({<br/>      enable      = optional(bool)<br/>      sample_rate = optional(number)<br/>      optional_mode = optional(string)<br/>    }))<br/>    http_adapter = optional(object({<br/>      enable        = optional(bool)<br/>      sample_rate = optional(number)<br/>      optional_mode = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_gcp_load_balancer_mqtt_timeout"></a> [gcp\_load\_balancer\_mqtt\_timeout](#input\_gcp\_load\_balancer\_mqtt\_timeout) | The timeout in seconds after which the connection will be closed by the load balancer if no communication occurred (should be longer than the keep-alive of the devices). | `number` | n/a | yes |
| <a name="input_gke_autopilot_enabled"></a> [gke\_autopilot\_enabled](#input\_gke\_autopilot\_enabled) | If autopilot mode should be enabled for the GKE cluster. | `bool` | n/a | yes |
| <a name="input_grafana_expose_externally"></a> [grafana\_expose\_externally](#input\_grafana\_expose\_externally) | Whether or not Grafana should be exposed externally. | `bool` | n/a | yes |
| <a name="input_hono_api_host_address"></a> [hono\_api\_host\_address](#input\_hono\_api\_host\_address) | Host address of your Hono API (e.g. api.hono.my-domain.com) | `string` | n/a | yes |
| <a name="input_hono_api_static_ip"></a> [hono\_api\_static\_ip](#input\_hono\_api\_static\_ip) | Static IP for External Ingress | `string` | n/a | yes |
| <a name="input_hono_root_domain"></a> [hono\_root\_domain](#input\_hono\_root\_domain) | The root domain of the Hono installation (e.g. hono.my-domain.com). | `string` | n/a | yes |
| <a name="input_http_adapter_static_ip"></a> [http\_adapter\_static\_ip](#input\_http\_adapter\_static\_ip) | Static ip address for the HTTP adapter loadbalancer. | `string` | n/a | yes |
| <a name="input_mqtt_adapter_static_ip"></a> [mqtt\_adapter\_static\_ip](#input\_mqtt\_adapter\_static\_ip) | Static ip address for the MQTT adapter loadbalancer. | `string` | n/a | yes |
| <a name="input_mqtt_rate_limiting"></a> [mqtt\_rate\_limiting](#input\_mqtt\_rate\_limiting) | Rate limiting configuration for the MQTT adapter. Only one of 'all' or 'ip' can take effect. If both are specified 'all' will take precedence. | <pre>object({<br/>    all = optional(object({<br/>      enable                 = optional(bool)<br/>      threshold_count        = optional(number)<br/>      threshold_interval_sec = optional(number)<br/>    }), {})<br/>    ip = optional(object({<br/>      enable                 = optional(bool)<br/>      threshold_count        = optional(number)<br/>      threshold_interval_sec = optional(number)<br/>    }), {})<br/>  })</pre> | n/a | yes |
| <a name="input_node_locations"></a> [node\_locations](#input\_node\_locations) | The zones the standard node pool will create nodes in (only applicable if cluster autopilot is disabled). IMPORTANT: The GCP Load Balancer will only create Network Endpoint Groups (NEGs) in these specified zones. Pods running in other zones will not be accessible via the load balancer. This limitation does not apply to the legacy load balancer setup ('legacy\_load\_balancer\_setup\_enabled = true'). | `list(string)` | n/a | yes |
| <a name="input_oauth_client_id"></a> [oauth\_client\_id](#input\_oauth\_client\_id) | The Google OAuth 2.0 client ID used in the Identity-Aware-Proxy (IAP) | `string` | n/a | yes |
| <a name="input_oauth_client_secret"></a> [oauth\_client\_secret](#input\_oauth\_client\_secret) | The Google OAuth 2.0 client secret used in the Identity-Aware-Proxy (IAP) | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID in which the cluster is present | `string` | n/a | yes |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | SSL policy for external ingress | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_adapter_dns_auth_resource_record"></a> [adapter\_dns\_auth\_resource\_record](#output\_adapter\_dns\_auth\_resource\_record) | n/a |

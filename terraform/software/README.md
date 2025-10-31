## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alert_policies"></a> [alert\_policies](#module\_alert\_policies) | ../modules/alert_policies | n/a |
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ../modules/cert_manager | n/a |
| <a name="module_gcp_load_balancer"></a> [gcp\_load\_balancer](#module\_gcp\_load\_balancer) | ../modules/gcp_load_balancer | n/a |
| <a name="module_hono"></a> [hono](#module\_hono) | ../modules/hono | n/a |
| <a name="module_namespace"></a> [namespace](#module\_namespace) | ../modules/namespace | n/a |
| <a name="module_stakater_reloader"></a> [stakater\_reloader](#module\_stakater\_reloader) | ../modules/stakater_reloader | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_zones.available_zones](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alerts_chat_space_id"></a> [alerts\_chat\_space\_id](#input\_alerts\_chat\_space\_id) | The Chat space ID is the string following “chat/space/” in the chat URL. It can only be seen in the web view of the Chat app. In order to add Google Chat as a notification channel, you must first add the Google Cloud Monitoring App to the chat space. You can add the app directly to a space by typing @Google Cloud Monitoring. | `string` | `null` | no |
| <a name="input_alerts_enabled"></a> [alerts\_enabled](#input\_alerts\_enabled) | If alerts should be enabled. | `bool` | `false` | no |
| <a name="input_cert_manager_cert_duration"></a> [cert\_manager\_cert\_duration](#input\_cert\_manager\_cert\_duration) | Validity period of a newly created certificate (e.g. 2160h for 90 day validity). | `string` | `"2160h"` | no |
| <a name="input_cert_manager_cert_renew_before"></a> [cert\_manager\_cert\_renew\_before](#input\_cert\_manager\_cert\_renew\_before) | When to renew the certificate based on its remaining validity period (e.g. 720h for 30 days before expiration). | `string` | `"720h"` | no |
| <a name="input_cert_manager_email"></a> [cert\_manager\_email](#input\_cert\_manager\_email) | E-Mail address to contact in case something goes wrong with the certificate renewal. | `string` | `""` | no |
| <a name="input_cert_manager_issuer_kind"></a> [cert\_manager\_issuer\_kind](#input\_cert\_manager\_issuer\_kind) | Kind of the cert-manager issuer (Issuer or ClusterIssuer). | `string` | `"ClusterIssuer"` | no |
| <a name="input_cert_manager_issuer_name"></a> [cert\_manager\_issuer\_name](#input\_cert\_manager\_issuer\_name) | Name of the cert-manager issuer. | `string` | `"letsencrypt-prod"` | no |
| <a name="input_cert_manager_issuer_project_id"></a> [cert\_manager\_issuer\_project\_id](#input\_cert\_manager\_issuer\_project\_id) | Project ID in which the Cloud DNS zone to manage the DNS entries is located. | `string` | `null` | no |
| <a name="input_cert_manager_namespace"></a> [cert\_manager\_namespace](#input\_cert\_manager\_namespace) | namespace of the cert manager deployment. | `string` | `"cert-manager"` | no |
| <a name="input_cert_manager_version"></a> [cert\_manager\_version](#input\_cert\_manager\_version) | Version of the chart to deploy. | `string` | `"1.12.2"` | no |
| <a name="input_cluster_self_signed_issuer_name"></a> [cluster\_self\_signed\_issuer\_name](#input\_cluster\_self\_signed\_issuer\_name) | Name of the issuer used for the clusters internal certification process, used by cert-manager. | `string` | `"selfsigned-issuer"` | no |
| <a name="input_data_grid_replicas"></a> [data\_grid\_replicas](#input\_data\_grid\_replicas) | Number of replicas for the data grid | `number` | `1` | no |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | Enables the use of cert manager. Only relevant if legacy\_load\_balancer\_setup\_enabled is set to true | `bool` | `false` | no |
| <a name="input_enable_http_adapter"></a> [enable\_http\_adapter](#input\_enable\_http\_adapter) | Used to enable the http adapter | `bool` | `false` | no |
| <a name="input_enable_mqtt_adapter"></a> [enable\_mqtt\_adapter](#input\_enable\_mqtt\_adapter) | Used to enable the mqtt adapter | `bool` | `true` | no |
| <a name="input_gcp_load_balancer_log_config"></a> [gcp\_load\_balancer\_log\_config](#input\_gcp\_load\_balancer\_log\_config) | Logging configuration for the backend services of the GCP load balancers. | <pre>object({<br/>    ui = optional(object({<br/>      enable        = optional(bool, false)<br/>      sample_rate   = optional(number, 1.0)<br/>      optional_mode = optional(string, "EXCLUDE_ALL_OPTIONAL")<br/>    }), {})<br/>    device_registry = optional(object({<br/>      enable        = optional(bool, false)<br/>      sample_rate   = optional(number, 1.0)<br/>      optional_mode = optional(string, "EXCLUDE_ALL_OPTIONAL")<br/>    }), {})<br/>    device_communication = optional(object({<br/>      enable        = optional(bool, false)<br/>      sample_rate   = optional(number, 1.0)<br/>      optional_mode = optional(string, "EXCLUDE_ALL_OPTIONAL")<br/>    }), {})<br/>    grafana = optional(object({<br/>      enable        = optional(bool, false)<br/>      sample_rate   = optional(number, 1.0)<br/>      optional_mode = optional(string, "EXCLUDE_ALL_OPTIONAL")<br/>    }), {})<br/>    mqtt_adapter = optional(object({<br/>      enable        = optional(bool, false)<br/>      sample_rate   = optional(number, 1.0)<br/>      optional_mode = optional(string, "EXCLUDE_ALL_OPTIONAL")<br/>    }), {})<br/>    http_adapter = optional(object({<br/>      enable        = optional(bool, false)<br/>      sample_rate   = optional(number, 1.0)<br/>      optional_mode = optional(string, "EXCLUDE_ALL_OPTIONAL")<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_gcp_load_balancer_mqtt_timeout"></a> [gcp\_load\_balancer\_mqtt\_timeout](#input\_gcp\_load\_balancer\_mqtt\_timeout) | The timeout in seconds after which the connection will be closed by the load balancer if no communication occurred (should be longer than the keep-alive of the devices). | `number` | `60` | no |
| <a name="input_gke_autopilot_enabled"></a> [gke\_autopilot\_enabled](#input\_gke\_autopilot\_enabled) | If autopilot mode should be enabled for the GKE cluster. | `bool` | n/a | yes |
| <a name="input_grafana_dns_name"></a> [grafana\_dns\_name](#input\_grafana\_dns\_name) | Name of the DNS host for Grafana. Only relevant if both grafana\_expose\_externally and legacy\_load\_balancer\_setup\_enabled are set to true. If Grafana is exposed with the legacy\_load\_balancer\_setup\_enabled=false it is reachable under "https://{hono_api_host_address}/grafana". | `string` | `""` | no |
| <a name="input_grafana_expose_externally"></a> [grafana\_expose\_externally](#input\_grafana\_expose\_externally) | Whether or not Grafana should be exposed externally. | `bool` | n/a | yes |
| <a name="input_grafana_static_ip_name"></a> [grafana\_static\_ip\_name](#input\_grafana\_static\_ip\_name) | Name of the static IP for external ingress. Only relevant if both grafana\_expose\_externally and legacy\_load\_balancer\_setup\_enabled are set to true | `string` | n/a | yes |
| <a name="input_helm_package_repository"></a> [helm\_package\_repository](#input\_helm\_package\_repository) | Link to the Helm Package for the Hono Deployment | `string` | n/a | yes |
| <a name="input_helm_release_name"></a> [helm\_release\_name](#input\_helm\_release\_name) | Name of the helm release | `string` | `"eclipse-hono"` | no |
| <a name="input_hono_api_host_address"></a> [hono\_api\_host\_address](#input\_hono\_api\_host\_address) | Host address of your Hono API (e.g. api.hono.my-domain.com) | `string` | n/a | yes |
| <a name="input_hono_api_static_ip"></a> [hono\_api\_static\_ip](#input\_hono\_api\_static\_ip) | Static IP for External Ingress | `string` | n/a | yes |
| <a name="input_hono_api_static_ip_name"></a> [hono\_api\_static\_ip\_name](#input\_hono\_api\_static\_ip\_name) | Name of the Static IP for External Ingress | `string` | n/a | yes |
| <a name="input_hono_chart_name"></a> [hono\_chart\_name](#input\_hono\_chart\_name) | Name of the Chart in the Repository | `string` | `"hono"` | no |
| <a name="input_hono_chart_version"></a> [hono\_chart\_version](#input\_hono\_chart\_version) | Version of the Chart in the Repository | `string` | `null` | no |
| <a name="input_hono_cluster_ca_issuer"></a> [hono\_cluster\_ca\_issuer](#input\_hono\_cluster\_ca\_issuer) | Name of the issuer used for the clusters application certification process, used by cert-manager. | `string` | `"hono-cluster-ca-issuer"` | no |
| <a name="input_hono_cluster_ca_name"></a> [hono\_cluster\_ca\_name](#input\_hono\_cluster\_ca\_name) | Name of the clusters internal ca for hono deployments internal communication, managed by cert-manager. | `string` | `"hono-cluster-ca"` | no |
| <a name="input_hono_cluster_ca_secret_name"></a> [hono\_cluster\_ca\_secret\_name](#input\_hono\_cluster\_ca\_secret\_name) | Name of the kubernetes secret containing the clusters internal ca.crt for hono deployments internal communication, managed by cert-manager. | `string` | `"hono-cluster-ca-secret"` | no |
| <a name="input_hono_domain_managed_secret_name"></a> [hono\_domain\_managed\_secret\_name](#input\_hono\_domain\_managed\_secret\_name) | Name of the kubernetes secret for the hono domain (wildcard) in case it is managed by cert-manager | `string` | `"hono-domain-managed-secret"` | no |
| <a name="input_hono_domain_secret_name"></a> [hono\_domain\_secret\_name](#input\_hono\_domain\_secret\_name) | Name of the kubernetes secret for the hono domain (wildcard) | `string` | `"hono-domain-secret"` | no |
| <a name="input_hono_internal_tls_cert_name"></a> [hono\_internal\_tls\_cert\_name](#input\_hono\_internal\_tls\_cert\_name) | Name of the Certificate resource for Hono internal TLS | `string` | `"hono-cluster-ca-signed-eclipse-hono-all-tls-secret"` | no |
| <a name="input_hono_internal_tls_secret_name"></a> [hono\_internal\_tls\_secret\_name](#input\_hono\_internal\_tls\_secret\_name) | Name of the kubernetes secret that will store the Hono internal TLS certificate | `string` | `"eclipse-hono-all-tls-secret"` | no |
| <a name="input_hono_namespace"></a> [hono\_namespace](#input\_hono\_namespace) | namespace of the deployment | `string` | `"hono"` | no |
| <a name="input_hono_root_domain"></a> [hono\_root\_domain](#input\_hono\_root\_domain) | The root domain of the Hono installation (e.g. hono.my-domain.com). | `string` | n/a | yes |
| <a name="input_hono_tls_crt"></a> [hono\_tls\_crt](#input\_hono\_tls\_crt) | Content of the hono domain tls Cert File | `string` | n/a | yes |
| <a name="input_hono_tls_crt_from_storage"></a> [hono\_tls\_crt\_from\_storage](#input\_hono\_tls\_crt\_from\_storage) | Content of the hono domain tls Cert File from storage bucket | `string` | n/a | yes |
| <a name="input_hono_tls_key"></a> [hono\_tls\_key](#input\_hono\_tls\_key) | Content of the hono domain tls Key File | `string` | n/a | yes |
| <a name="input_hono_tls_key_from_storage"></a> [hono\_tls\_key\_from\_storage](#input\_hono\_tls\_key\_from\_storage) | Content of the hono domain tls Key File from storage bucket | `string` | n/a | yes |
| <a name="input_hono_trust_store_config_map_name"></a> [hono\_trust\_store\_config\_map\_name](#input\_hono\_trust\_store\_config\_map\_name) | Name of the kubernetes trust store config map for the hono deployments managed by trust-manager. | `string` | `"hono-trust-store-config-map"` | no |
| <a name="input_hpa_enabled"></a> [hpa\_enabled](#input\_hpa\_enabled) | Enables the creation of a horizontal pod autoscaler for the MQTT adapter and the device registry. | `bool` | `false` | no |
| <a name="input_hpa_maxReplicas_device_registry"></a> [hpa\_maxReplicas\_device\_registry](#input\_hpa\_maxReplicas\_device\_registry) | Maximum number of replicas the device registry horizontal pod autoscaler can scale to. | `number` | `5` | no |
| <a name="input_hpa_maxReplicas_mqtt"></a> [hpa\_maxReplicas\_mqtt](#input\_hpa\_maxReplicas\_mqtt) | Maximum number of replicas the horizontal pod autoscaler can scale to. | `number` | `10` | no |
| <a name="input_hpa_metrics_mqtt"></a> [hpa\_metrics\_mqtt](#input\_hpa\_metrics\_mqtt) | Metrics for the MQTT horizontal pod autoscaler as JSON list. | `list` | <pre>[<br/>  {<br/>    "pods": {<br/>      "metric": {<br/>        "name": "hono_connections_authenticated"<br/>      },<br/>      "target": {<br/>        "averageValue": "10000",<br/>        "type": "AverageValue"<br/>      }<br/>    },<br/>    "type": "Pods"<br/>  },<br/>  {<br/>    "resource": {<br/>      "name": "cpu",<br/>      "target": {<br/>        "averageUtilization": 80,<br/>        "type": "Utilization"<br/>      }<br/>    },<br/>    "type": "Resource"<br/>  },<br/>  {<br/>    "resource": {<br/>      "name": "memory",<br/>      "target": {<br/>        "averageUtilization": 85,<br/>        "type": "Utilization"<br/>      }<br/>    },<br/>    "type": "Resource"<br/>  }<br/>]</pre> | no |
| <a name="input_hpa_minReplicas_device_registry"></a> [hpa\_minReplicas\_device\_registry](#input\_hpa\_minReplicas\_device\_registry) | Minimum number of replicas the device registry horizontal pod autoscaler can scale to. | `number` | `1` | no |
| <a name="input_hpa_minReplicas_mqtt"></a> [hpa\_minReplicas\_mqtt](#input\_hpa\_minReplicas\_mqtt) | Minimum number of replicas the horizontal pod autoscaler can scale to. | `number` | `1` | no |
| <a name="input_http_adapter_static_ip"></a> [http\_adapter\_static\_ip](#input\_http\_adapter\_static\_ip) | Static ip address for the HTTP adapter loadbalancer. | `string` | n/a | yes |
| <a name="input_legacy_load_balancer_setup_enabled"></a> [legacy\_load\_balancer\_setup\_enabled](#input\_legacy\_load\_balancer\_setup\_enabled) | Whether the legacy load balancer setup with Kubernetes Ingress and Cloud Endpoints should be enabled. | `bool` | n/a | yes |
| <a name="input_mqtt_adapter_static_ip"></a> [mqtt\_adapter\_static\_ip](#input\_mqtt\_adapter\_static\_ip) | Static ip address for the MQTT adapter loadbalancer. | `string` | n/a | yes |
| <a name="input_mqtt_rate_limiting"></a> [mqtt\_rate\_limiting](#input\_mqtt\_rate\_limiting) | Rate limiting configuration for the MQTT adapter. Only one of 'all' or 'ip' can take effect. If both are specified 'all' will take precedence. | <pre>object({<br/>    all = optional(object({<br/>      enable                 = optional(bool, false)<br/>      threshold_count        = optional(number, 100)<br/>      threshold_interval_sec = optional(number, 10)<br/>    }), {})<br/>    ip = optional(object({<br/>      enable                 = optional(bool, false)<br/>      threshold_count        = optional(number, 5)<br/>      threshold_interval_sec = optional(number, 10)<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_node_locations"></a> [node\_locations](#input\_node\_locations) | The zones the standard node pool will create nodes in (only applicable if cluster autopilot is disabled). IMPORTANT: The GCP Load Balancer will only create Network Endpoint Groups (NEGs) in these specified zones. Pods running in other zones will not be accessible via the load balancer. This limitation does not apply to the legacy load balancer setup ('legacy\_load\_balancer\_setup\_enabled = true'). | `list(string)` | n/a | yes |
| <a name="input_oauth_app_name"></a> [oauth\_app\_name](#input\_oauth\_app\_name) | Name of the Application | `string` | n/a | yes |
| <a name="input_oauth_client_id"></a> [oauth\_client\_id](#input\_oauth\_client\_id) | The Google OAuth 2.0 client ID used in the Identity-Aware-Proxy (IAP) | `string` | n/a | yes |
| <a name="input_oauth_client_secret"></a> [oauth\_client\_secret](#input\_oauth\_client\_secret) | The Google OAuth 2.0 client secret used in the Identity-Aware-Proxy (IAP) | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID in which the cluster is present | `string` | n/a | yes |
| <a name="input_prometheus_adapter_custom_metrics"></a> [prometheus\_adapter\_custom\_metrics](#input\_prometheus\_adapter\_custom\_metrics) | Prometheus metrics to expose via the prometheus adapter to use as custom metrics in horizontal pod autoscaler. | `list` | <pre>[<br/>  {<br/>    "metricsQuery": "sum(hono_connections_authenticated{<<.LabelMatchers>>}) by (<<.GroupBy>>)",<br/>    "resources": {<br/>      "overrides": {<br/>        "kubernetes_namespace": {<br/>          "resource": "namespace"<br/>        },<br/>        "kubernetes_pod_name": {<br/>          "resource": "pod"<br/>        }<br/>      }<br/>    },<br/>    "seriesQuery": "hono_connections_authenticated{kubernetes_namespace!=\"\",kubernetes_pod_name!=\"\"}"<br/>  }<br/>]</pre> | no |
| <a name="input_prometheus_adapter_version"></a> [prometheus\_adapter\_version](#input\_prometheus\_adapter\_version) | Version of the prometheus-adapter helm chart. | `string` | `"4.4.1"` | no |
| <a name="input_reloader_version"></a> [reloader\_version](#input\_reloader\_version) | Version of the stakater reloader helm chart. | `string` | `"v1.0.29"` | no |
| <a name="input_service_name_communication"></a> [service\_name\_communication](#input\_service\_name\_communication) | name of the Cloud Endpoint service for device communication | `string` | n/a | yes |
| <a name="input_sql_db_pw"></a> [sql\_db\_pw](#input\_sql\_db\_pw) | password for the sql\_user for the database | `string` | n/a | yes |
| <a name="input_sql_grafana_database"></a> [sql\_grafana\_database](#input\_sql\_grafana\_database) | Name of the postgres database for Grafana. | `string` | n/a | yes |
| <a name="input_sql_hono_database"></a> [sql\_hono\_database](#input\_sql\_hono\_database) | Name of the postgres database for Hono. | `string` | n/a | yes |
| <a name="input_sql_ip"></a> [sql\_ip](#input\_sql\_ip) | URL of the Postgres Database | `string` | n/a | yes |
| <a name="input_sql_user"></a> [sql\_user](#input\_sql\_user) | username of the sql database username | `string` | n/a | yes |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | SSL policy for external ingress. | `string` | n/a | yes |
| <a name="input_trust_manager_version"></a> [trust\_manager\_version](#input\_trust\_manager\_version) | Version of the chart to deploy. | `string` | `"0.5.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_adapter_dns_auth_resource_record"></a> [adapter\_dns\_auth\_resource\_record](#output\_adapter\_dns\_auth\_resource\_record) | n/a |
| <a name="output_hono_tls_crt_in_storage"></a> [hono\_tls\_crt\_in\_storage](#output\_hono\_tls\_crt\_in\_storage) | n/a |
| <a name="output_hono_tls_key_in_storage"></a> [hono\_tls\_key\_in\_storage](#output\_hono\_tls\_key\_in\_storage) | n/a |
| <a name="output_values"></a> [values](#output\_values) | n/a |

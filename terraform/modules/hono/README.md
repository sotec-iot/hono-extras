## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_member.gke_binding_cloudtrace_agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.gke_binding_pubsub_editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account_iam_binding.esp_workload_identity_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [helm_release.hono](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus_adapter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_annotations.sa_service_esp_annotation](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/annotations) | resource |
| [kubernetes_secret.hono_domain_secret_tls](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.iap_client_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_manager_enabled"></a> [cert\_manager\_enabled](#input\_cert\_manager\_enabled) | Disables the creation of TLS secrets to manually maintain | `bool` | n/a | yes |
| <a name="input_data_grid_replicas"></a> [data\_grid\_replicas](#input\_data\_grid\_replicas) | Number of replicas for the data grid | `number` | n/a | yes |
| <a name="input_enable_http_adapter"></a> [enable\_http\_adapter](#input\_enable\_http\_adapter) | Used to enable the http adapter | `bool` | n/a | yes |
| <a name="input_enable_mqtt_adapter"></a> [enable\_mqtt\_adapter](#input\_enable\_mqtt\_adapter) | Used to enable the mqtt adapter | `bool` | n/a | yes |
| <a name="input_grafana_dns_name"></a> [grafana\_dns\_name](#input\_grafana\_dns\_name) | Name of the DNS host for Grafana. Only relevant if both grafana\_expose\_externally and legacy\_load\_balancer\_setup\_enabled are set to true. If Grafana is exposed with the legacy\_load\_balancer\_setup\_enabled=false it is reachable under "https://{hono_api_host_address}/grafana". | `string` | n/a | yes |
| <a name="input_grafana_expose_externally"></a> [grafana\_expose\_externally](#input\_grafana\_expose\_externally) | Whether or not Grafana should be exposed externally. | `bool` | n/a | yes |
| <a name="input_grafana_static_ip_name"></a> [grafana\_static\_ip\_name](#input\_grafana\_static\_ip\_name) | Name of the static IP for external ingress. Only relevant if both grafana\_expose\_externally and legacy\_load\_balancer\_setup\_enabled are set to true | `string` | n/a | yes |
| <a name="input_helm_package_repository"></a> [helm\_package\_repository](#input\_helm\_package\_repository) | Link to the Helm Package for the Hono Deployment | `string` | n/a | yes |
| <a name="input_helm_release_name"></a> [helm\_release\_name](#input\_helm\_release\_name) | Name of the helm realease | `string` | n/a | yes |
| <a name="input_hono_api_host_address"></a> [hono\_api\_host\_address](#input\_hono\_api\_host\_address) | Host address of your Hono API (e.g. api.hono.my-domain.com) | `string` | n/a | yes |
| <a name="input_hono_api_static_ip_name"></a> [hono\_api\_static\_ip\_name](#input\_hono\_api\_static\_ip\_name) | Name of the Static IP for External Ingress | `string` | n/a | yes |
| <a name="input_hono_chart_name"></a> [hono\_chart\_name](#input\_hono\_chart\_name) | Name of the Chart in the Repository | `string` | n/a | yes |
| <a name="input_hono_chart_version"></a> [hono\_chart\_version](#input\_hono\_chart\_version) | Version of the Chart in the Repository | `string` | n/a | yes |
| <a name="input_hono_domain_managed_secret_name"></a> [hono\_domain\_managed\_secret\_name](#input\_hono\_domain\_managed\_secret\_name) | Name of the kubernetes secret for the hono domain (wildcard) in case it is managed by cert-manager | `string` | n/a | yes |
| <a name="input_hono_domain_secret_name"></a> [hono\_domain\_secret\_name](#input\_hono\_domain\_secret\_name) | Name of the kubernetes secret for the hono domain (wildcard) | `string` | n/a | yes |
| <a name="input_hono_namespace"></a> [hono\_namespace](#input\_hono\_namespace) | namespace of the hono deployment | `string` | n/a | yes |
| <a name="input_hono_tls_crt"></a> [hono\_tls\_crt](#input\_hono\_tls\_crt) | Content of the hono domain tls Cert File | `string` | n/a | yes |
| <a name="input_hono_tls_crt_from_storage"></a> [hono\_tls\_crt\_from\_storage](#input\_hono\_tls\_crt\_from\_storage) | Content of the hono domain tls Cert File from storage bucket | `string` | n/a | yes |
| <a name="input_hono_tls_key"></a> [hono\_tls\_key](#input\_hono\_tls\_key) | Content of the hono domain tls Key File | `string` | n/a | yes |
| <a name="input_hono_tls_key_from_storage"></a> [hono\_tls\_key\_from\_storage](#input\_hono\_tls\_key\_from\_storage) | Content of the hono domain tls Key File from storage bucket | `string` | n/a | yes |
| <a name="input_hono_trust_store_config_map_name"></a> [hono\_trust\_store\_config\_map\_name](#input\_hono\_trust\_store\_config\_map\_name) | Name of the kubernetes trust store config map for the hono deployments managed by trust-manager. | `string` | n/a | yes |
| <a name="input_hpa_enabled"></a> [hpa\_enabled](#input\_hpa\_enabled) | Enables the creation of horizontal pod autoscaler for the MQTT adapter and the device registry. | `bool` | n/a | yes |
| <a name="input_hpa_maxReplicas_device_registry"></a> [hpa\_maxReplicas\_device\_registry](#input\_hpa\_maxReplicas\_device\_registry) | Maximum number of replicas that the horizontal pod autoscaler can spawn for the device registry deployment. | `number` | n/a | yes |
| <a name="input_hpa_maxReplicas_mqtt"></a> [hpa\_maxReplicas\_mqtt](#input\_hpa\_maxReplicas\_mqtt) | Maximum number of replicas that the horizontal pod autoscaler can spawn for the MQTT adapter deployment. | `number` | n/a | yes |
| <a name="input_hpa_metrics_mqtt"></a> [hpa\_metrics\_mqtt](#input\_hpa\_metrics\_mqtt) | Metrics for the MQTT horizontal pod autoscaler as JSON list. | `any` | n/a | yes |
| <a name="input_hpa_minReplicas_device_registry"></a> [hpa\_minReplicas\_device\_registry](#input\_hpa\_minReplicas\_device\_registry) | Minimum number of replicas that the horizontal pod autoscaler must maintain for the device registry deployment. | `number` | n/a | yes |
| <a name="input_hpa_minReplicas_mqtt"></a> [hpa\_minReplicas\_mqtt](#input\_hpa\_minReplicas\_mqtt) | Minimum number of replicas that the horizontal pod autoscaler must maintain for the MQTT adapter deployment. | `number` | n/a | yes |
| <a name="input_http_adapter_static_ip"></a> [http\_adapter\_static\_ip](#input\_http\_adapter\_static\_ip) | Static ip address for the HTTP adapter loadbalancer. | `string` | n/a | yes |
| <a name="input_legacy_load_balancer_setup_enabled"></a> [legacy\_load\_balancer\_setup\_enabled](#input\_legacy\_load\_balancer\_setup\_enabled) | Whether the legacy load balancer setup with Kubernetes Ingress, Cloud Endpoints and Cert Manager should be enabled. | `bool` | n/a | yes |
| <a name="input_mqtt_adapter_static_ip"></a> [mqtt\_adapter\_static\_ip](#input\_mqtt\_adapter\_static\_ip) | Static ip address for the MQTT adapter loadbalancer. | `string` | n/a | yes |
| <a name="input_oauth_app_name"></a> [oauth\_app\_name](#input\_oauth\_app\_name) | Name of the OAuth Application | `string` | n/a | yes |
| <a name="input_oauth_client_id"></a> [oauth\_client\_id](#input\_oauth\_client\_id) | The Google OAuth 2.0 client ID used in the Identity-Aware-Proxy (IAP) | `string` | n/a | yes |
| <a name="input_oauth_client_secret"></a> [oauth\_client\_secret](#input\_oauth\_client\_secret) | The Google OAuth 2.0 client secret used in the Identity-Aware-Proxy (IAP) | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID in which the cluster is present | `string` | n/a | yes |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | Project number of the project in which the cluster is present | `string` | n/a | yes |
| <a name="input_prometheus_adapter_custom_metrics"></a> [prometheus\_adapter\_custom\_metrics](#input\_prometheus\_adapter\_custom\_metrics) | Prometheus metrics to expose via the prometheus adapter to use as custom metrics in horizontal pod autoscaler. | `any` | n/a | yes |
| <a name="input_prometheus_adapter_version"></a> [prometheus\_adapter\_version](#input\_prometheus\_adapter\_version) | Version of the prometheus-adapter helm chart. | `string` | n/a | yes |
| <a name="input_service_name_communication"></a> [service\_name\_communication](#input\_service\_name\_communication) | Name of the Cloud Endpoint service for device communication | `string` | n/a | yes |
| <a name="input_sql_db_pw"></a> [sql\_db\_pw](#input\_sql\_db\_pw) | password for the sql\_user for the database | `string` | n/a | yes |
| <a name="input_sql_grafana_database"></a> [sql\_grafana\_database](#input\_sql\_grafana\_database) | Name of the postgres database for Grafana. | `string` | n/a | yes |
| <a name="input_sql_hono_database"></a> [sql\_hono\_database](#input\_sql\_hono\_database) | Name of the postgres database for Hono. | `string` | n/a | yes |
| <a name="input_sql_ip"></a> [sql\_ip](#input\_sql\_ip) | URL of the Postgres Database | `string` | n/a | yes |
| <a name="input_sql_user"></a> [sql\_user](#input\_sql\_user) | username of the sql database username | `string` | n/a | yes |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | SSL policy for external ingress | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_values"></a> [values](#output\_values) | n/a |

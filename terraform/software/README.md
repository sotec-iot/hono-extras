## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_hono"></a> [hono](#module\_hono) | ../modules/hono | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_tls_crt"></a> [api\_tls\_crt](#input\_api\_tls\_crt) | Content of the ingress tls/server Cert File | `string` | n/a | yes |
| <a name="input_api_tls_crt_from_storage"></a> [api\_tls\_crt\_from\_storage](#input\_api\_tls\_crt\_from\_storage) | Content of the ingress tls/server Cert File from storage bucket | `string` | n/a | yes |
| <a name="input_api_tls_key"></a> [api\_tls\_key](#input\_api\_tls\_key) | Content of the ingress tls/server Key File | `string` | n/a | yes |
| <a name="input_api_tls_key_from_storage"></a> [api\_tls\_key\_from\_storage](#input\_api\_tls\_key\_from\_storage) | Content of the ingress tls/server Key File from storage bucket | `string` | n/a | yes |
| <a name="input_cloud_endpoints_key_file"></a> [cloud\_endpoints\_key\_file](#input\_cloud\_endpoints\_key\_file) | Service Account Key File for Cloud Endpoints Service Account | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | name of the autopilot cluster | `string` | n/a | yes |
| <a name="input_device_communication_dns_name"></a> [device\_communication\_dns\_name](#input\_device\_communication\_dns\_name) | Name of the DNS Host | `string` | n/a | yes |
| <a name="input_device_communication_static_ip_name"></a> [device\_communication\_static\_ip\_name](#input\_device\_communication\_static\_ip\_name) | Name of the Static IP for External Ingress | `string` | n/a | yes |
| <a name="input_enable_http_adapter"></a> [enable\_http\_adapter](#input\_enable\_http\_adapter) | Used to enable the http adapter | `bool` | `false` | no |
| <a name="input_enable_mqtt_adapter"></a> [enable\_mqtt\_adapter](#input\_enable\_mqtt\_adapter) | Used to enable the mqtt adapter | `bool` | `true` | no |
| <a name="input_helm_package_repository"></a> [helm\_package\_repository](#input\_helm\_package\_repository) | Link to the Helm Package for the Hono Deployment | `string` | n/a | yes |
| <a name="input_hono_chart_name"></a> [hono\_chart\_name](#input\_hono\_chart\_name) | Name of the Chart in the Repository | `string` | `"hono"` | no |
| <a name="input_hono_chart_version"></a> [hono\_chart\_version](#input\_hono\_chart\_version) | Version of the Chart in the Repository | `string` | `null` | no |
| <a name="input_http_secret_name"></a> [http\_secret\_name](#input\_http\_secret\_name) | Name of the kubernetes secret for the http adapter | `string` | `"hono-http-secret"` | no |
| <a name="input_http_static_ip"></a> [http\_static\_ip](#input\_http\_static\_ip) | static ip address for the http loadbalancer | `string` | n/a | yes |
| <a name="input_http_tls_crt"></a> [http\_tls\_crt](#input\_http\_tls\_crt) | Content of the http tls Cert File | `string` | n/a | yes |
| <a name="input_http_tls_crt_from_storage"></a> [http\_tls\_crt\_from\_storage](#input\_http\_tls\_crt\_from\_storage) | Content of the http tls Cert File from storage bucket | `string` | n/a | yes |
| <a name="input_http_tls_key"></a> [http\_tls\_key](#input\_http\_tls\_key) | Content of the http tls Key File | `string` | n/a | yes |
| <a name="input_http_tls_key_from_storage"></a> [http\_tls\_key\_from\_storage](#input\_http\_tls\_key\_from\_storage) | Content of the http tls Key File from storage bucket | `string` | n/a | yes |
| <a name="input_ingress_secret_name"></a> [ingress\_secret\_name](#input\_ingress\_secret\_name) | Name of the kubernetes secret for the ingress | `string` | `"ingress-secret-tls"` | no |
| <a name="input_mqtt_secret_name"></a> [mqtt\_secret\_name](#input\_mqtt\_secret\_name) | Name of the kubernetes secret for the mqtt adapter | `string` | `"hono-mqtt-secret"` | no |
| <a name="input_mqtt_static_ip"></a> [mqtt\_static\_ip](#input\_mqtt\_static\_ip) | static ip address for the mqtt loadbalancer | `string` | n/a | yes |
| <a name="input_mqtt_tls_crt"></a> [mqtt\_tls\_crt](#input\_mqtt\_tls\_crt) | Content of the mqtt tls Cert File | `string` | n/a | yes |
| <a name="input_mqtt_tls_crt_from_storage"></a> [mqtt\_tls\_crt\_from\_storage](#input\_mqtt\_tls\_crt\_from\_storage) | Content of the mqtt tls Cert File from storage bucket | `string` | n/a | yes |
| <a name="input_mqtt_tls_key"></a> [mqtt\_tls\_key](#input\_mqtt\_tls\_key) | Content of the mqtt tls Key File | `string` | n/a | yes |
| <a name="input_mqtt_tls_key_from_storage"></a> [mqtt\_tls\_key\_from\_storage](#input\_mqtt\_tls\_key\_from\_storage) | Content of the mqtt tls Key File from storage bucket | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | namespace of the deployment | `string` | `"hono"` | no |
| <a name="input_oauth_app_name"></a> [oauth\_app\_name](#input\_oauth\_app\_name) | Name of the Application | `string` | n/a | yes |
| <a name="input_oauth_client_id"></a> [oauth\_client\_id](#input\_oauth\_client\_id) | The Google OAuth 2.0 client ID used in the Identity-Aware-Proxy (IAP) | `string` | n/a | yes |
| <a name="input_oauth_client_secret"></a> [oauth\_client\_secret](#input\_oauth\_client\_secret) | The Google OAuth 2.0 client secret used in the Identity-Aware-Proxy (IAP) | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID in which the cluster is present | `string` | n/a | yes |
| <a name="input_service_name_communication"></a> [service\_name\_communication](#input\_service\_name\_communication) | name of the Cloud Endpoint service for device communication | `string` | n/a | yes |
| <a name="input_sql_database"></a> [sql\_database](#input\_sql\_database) | name of the Postgres Database | `string` | n/a | yes |
| <a name="input_sql_db_pw"></a> [sql\_db\_pw](#input\_sql\_db\_pw) | password for the sql\_user for the database | `string` | n/a | yes |
| <a name="input_sql_ip"></a> [sql\_ip](#input\_sql\_ip) | URL of the Postgres Database | `string` | n/a | yes |
| <a name="input_sql_user"></a> [sql\_user](#input\_sql\_user) | username of the sql database username | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_tls_crt_in_storage"></a> [api\_tls\_crt\_in\_storage](#output\_api\_tls\_crt\_in\_storage) | n/a |
| <a name="output_api_tls_key_in_storage"></a> [api\_tls\_key\_in\_storage](#output\_api\_tls\_key\_in\_storage) | n/a |
| <a name="output_http_tls_crt_in_storage"></a> [http\_tls\_crt\_in\_storage](#output\_http\_tls\_crt\_in\_storage) | n/a |
| <a name="output_http_tls_key_in_storage"></a> [http\_tls\_key\_in\_storage](#output\_http\_tls\_key\_in\_storage) | n/a |
| <a name="output_mqtt_tls_crt_in_storage"></a> [mqtt\_tls\_crt\_in\_storage](#output\_mqtt\_tls\_crt\_in\_storage) | n/a |
| <a name="output_mqtt_tls_key_in_storage"></a> [mqtt\_tls\_key\_in\_storage](#output\_mqtt\_tls\_key\_in\_storage) | n/a |
| <a name="output_values"></a> [values](#output\_values) | n/a |

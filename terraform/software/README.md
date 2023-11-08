<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cert-manager"></a> [cert-manager](#module\_cert-manager) | ../modules/cert_manager | n/a |
| <a name="module_hono"></a> [hono](#module\_hono) | ../modules/hono | n/a |
| <a name="module_load-balancer"></a> [load-balancer](#module\_load-balancer) | ../modules/load_balancer | n/a |
| <a name="module_namespace"></a> [namespace](#module\_namespace) | ../modules/namespace | n/a |
| <a name="module_stakater-reloader"></a> [stakater-reloader](#module\_stakater-reloader) | ../modules/stakater_reloader | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_manager_cert_duration"></a> [cert\_manager\_cert\_duration](#input\_cert\_manager\_cert\_duration) | Validity period of a newly created certificate (e.g. 2160h for 90 day validity). | `string` | `"2160h"` | no |
| <a name="input_cert_manager_cert_renew_before"></a> [cert\_manager\_cert\_renew\_before](#input\_cert\_manager\_cert\_renew\_before) | When to renew the certificate based on its remaining validity period (e.g. 720h for 30 days before expiration). | `string` | `"720h"` | no |
| <a name="input_cert_manager_email"></a> [cert\_manager\_email](#input\_cert\_manager\_email) | E-Mail address to contact in case something goes wrong with the certificate renewal. | `string` | n/a | yes |
| <a name="input_cert_manager_issuer_kind"></a> [cert\_manager\_issuer\_kind](#input\_cert\_manager\_issuer\_kind) | Kind of the cert-manager issuer (Issuer or ClusterIssuer). | `string` | `"ClusterIssuer"` | no |
| <a name="input_cert_manager_issuer_name"></a> [cert\_manager\_issuer\_name](#input\_cert\_manager\_issuer\_name) | Name of the cert-manager issuer. | `string` | `"letsencrypt-prod"` | no |
| <a name="input_cert_manager_issuer_project_id"></a> [cert\_manager\_issuer\_project\_id](#input\_cert\_manager\_issuer\_project\_id) | Project ID in which the Cloud DNS zone to manage the DNS entries is located. | `string` | n/a | yes |
| <a name="input_cert_manager_namespace"></a> [cert\_manager\_namespace](#input\_cert\_manager\_namespace) | namespace of the cert manager deployment. | `string` | `"cert-manager"` | no |
| <a name="input_cert_manager_sa_account_id"></a> [cert\_manager\_sa\_account\_id](#input\_cert\_manager\_sa\_account\_id) | Account id of the cert-manager Service Account. | `string` | n/a | yes |
| <a name="input_cert_manager_sa_key_file"></a> [cert\_manager\_sa\_key\_file](#input\_cert\_manager\_sa\_key\_file) | Service Account Key File for cert-manager Service Account. | `string` | n/a | yes |
| <a name="input_cert_manager_version"></a> [cert\_manager\_version](#input\_cert\_manager\_version) | Version of the chart to deploy. | `string` | `"1.12.2"` | no |
| <a name="input_cloud_endpoints_key_file"></a> [cloud\_endpoints\_key\_file](#input\_cloud\_endpoints\_key\_file) | Service Account Key File for Cloud Endpoints Service Account | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | name of the autopilot cluster | `string` | n/a | yes |
| <a name="input_device_communication_dns_name"></a> [device\_communication\_dns\_name](#input\_device\_communication\_dns\_name) | Name of the DNS Host | `string` | n/a | yes |
| <a name="input_device_communication_static_ip_name"></a> [device\_communication\_static\_ip\_name](#input\_device\_communication\_static\_ip\_name) | Name of the Static IP for External Ingress | `string` | n/a | yes |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | Enables the use of cert manager. | `bool` | `false` | no |
| <a name="input_enable_http_adapter"></a> [enable\_http\_adapter](#input\_enable\_http\_adapter) | Used to enable the http adapter | `bool` | `false` | no |
| <a name="input_enable_mqtt_adapter"></a> [enable\_mqtt\_adapter](#input\_enable\_mqtt\_adapter) | Used to enable the mqtt adapter | `bool` | `true` | no |
| <a name="input_enhanced_mqtt_load_balancer"></a> [enhanced\_mqtt\_load\_balancer](#input\_enhanced\_mqtt\_load\_balancer) | Configuration options for the enhanced MQTT load balancer.<br>  enabled: Enables the use of the enhanced MQTT load balancer.<br>  chart\_version: Version of the chart to deploy.<br>  algorithm: Load balancing algorithm used by the enhanced MQTT load balancer. For a list of possible options see https://www.haproxy.com/documentation/kubernetes-ingress/community/configuration-reference/ingress/#load-balance .<br>  replicaCount: Number of replicas to deploy.<br>  port\_configs: List of MQTT port config objects for the enhanced MQTT load balancer service.<br>  tcp\_configmap\_data: Data of the TCP configMap for the enhanced MQTT load balancer. | <pre>object({<br>    enabled = optional(bool, true),<br>    chart_version = optional(string, "1.34.1"),<br>    algorithm = optional(string, "leastconn"),<br>    replicaCount = optional(number, 1),<br>    port_configs = optional(list(object({<br>      name       = string,<br>      port       = number,<br>      targetPort = optional(number, 8883)<br>    })), [<br>            {<br>              name: "mqtt"<br>              port: 8883<br>              targetPort: 8883<br>            }<br>          ]),<br>    tcp_configmap_data = optional(map(string), {<br>            8883 = "hono/eclipse-hono-adapter-mqtt:8883"<br>          })<br>  })</pre> | `{}` | no |
| <a name="input_grafana_dns_name"></a> [grafana\_dns\_name](#input\_grafana\_dns\_name) | Name of the DNS host for Grafana | `string` | `""` | no |
| <a name="input_grafana_expose_externally"></a> [grafana\_expose\_externally](#input\_grafana\_expose\_externally) | Whether or not Grafana should be exposed externally. | `bool` | n/a | yes |
| <a name="input_grafana_static_ip_name"></a> [grafana\_static\_ip\_name](#input\_grafana\_static\_ip\_name) | Name of the static IP for external ingress. | `string` | n/a | yes |
| <a name="input_helm_package_repository"></a> [helm\_package\_repository](#input\_helm\_package\_repository) | Link to the Helm Package for the Hono Deployment | `string` | n/a | yes |
| <a name="input_hono_chart_name"></a> [hono\_chart\_name](#input\_hono\_chart\_name) | Name of the Chart in the Repository | `string` | `"hono"` | no |
| <a name="input_hono_chart_version"></a> [hono\_chart\_version](#input\_hono\_chart\_version) | Version of the Chart in the Repository | `string` | `null` | no |
| <a name="input_hono_domain_managed_secret_name"></a> [hono\_domain\_managed\_secret\_name](#input\_hono\_domain\_managed\_secret\_name) | Name of the kubernetes secret for the hono domain (wildcard) in case it is managed by cert-manager | `string` | `"hono-domain-managed-secret"` | no |
| <a name="input_hono_domain_secret_name"></a> [hono\_domain\_secret\_name](#input\_hono\_domain\_secret\_name) | Name of the kubernetes secret for the hono domain (wildcard) | `string` | `"hono-domain-secret"` | no |
| <a name="input_hono_namespace"></a> [hono\_namespace](#input\_hono\_namespace) | namespace of the deployment | `string` | `"hono"` | no |
| <a name="input_hono_tls_crt"></a> [hono\_tls\_crt](#input\_hono\_tls\_crt) | Content of the hono domain tls Cert File | `string` | n/a | yes |
| <a name="input_hono_tls_crt_from_storage"></a> [hono\_tls\_crt\_from\_storage](#input\_hono\_tls\_crt\_from\_storage) | Content of the hono domain tls Cert File from storage bucket | `string` | n/a | yes |
| <a name="input_hono_tls_key"></a> [hono\_tls\_key](#input\_hono\_tls\_key) | Content of the hono domain tls Key File | `string` | n/a | yes |
| <a name="input_hono_tls_key_from_storage"></a> [hono\_tls\_key\_from\_storage](#input\_hono\_tls\_key\_from\_storage) | Content of the hono domain tls Key File from storage bucket | `string` | n/a | yes |
| <a name="input_hono_trust_store_config_map_name"></a> [hono\_trust\_store\_config\_map\_name](#input\_hono\_trust\_store\_config\_map\_name) | Name of the kubernetes trust store config map for the hono deployments managed by trust-manager. | `string` | `"hono-trust-store-config-map"` | no |
| <a name="input_hpa_enabled"></a> [hpa\_enabled](#input\_hpa\_enabled) | Enables the creation of a horizontal pod autoscaler for the MQTT adapter and the device registry. | `bool` | `false` | no |
| <a name="input_hpa_maxReplicas_device_registry"></a> [hpa\_maxReplicas\_device\_registry](#input\_hpa\_maxReplicas\_device\_registry) | Maximum number of replicas the device registry horizontal pod autoscaler can scale to. | `number` | `5` | no |
| <a name="input_hpa_maxReplicas_mqtt"></a> [hpa\_maxReplicas\_mqtt](#input\_hpa\_maxReplicas\_mqtt) | Maximum number of replicas the horizontal pod autoscaler can scale to. | `number` | `10` | no |
| <a name="input_hpa_metrics_mqtt"></a> [hpa\_metrics\_mqtt](#input\_hpa\_metrics\_mqtt) | Metrics for the MQTT horizontal pod autoscaler as JSON list. | `list` | <pre>[<br>  {<br>    "pods": {<br>      "metric": {<br>        "name": "hono_connections_authenticated"<br>      },<br>      "target": {<br>        "averageValue": "10000",<br>        "type": "AverageValue"<br>      }<br>    },<br>    "type": "Pods"<br>  },<br>  {<br>    "resource": {<br>      "name": "cpu",<br>      "target": {<br>        "averageUtilization": 80,<br>        "type": "Utilization"<br>      }<br>    },<br>    "type": "Resource"<br>  },<br>  {<br>    "resource": {<br>      "name": "memory",<br>      "target": {<br>        "averageUtilization": 85,<br>        "type": "Utilization"<br>      }<br>    },<br>    "type": "Resource"<br>  }<br>]</pre> | no |
| <a name="input_hpa_minReplicas_device_registry"></a> [hpa\_minReplicas\_device\_registry](#input\_hpa\_minReplicas\_device\_registry) | Minimum number of replicas the device registry horizontal pod autoscaler can scale to. | `number` | `1` | no |
| <a name="input_hpa_minReplicas_mqtt"></a> [hpa\_minReplicas\_mqtt](#input\_hpa\_minReplicas\_mqtt) | Minimum number of replicas the horizontal pod autoscaler can scale to. | `number` | `1` | no |
| <a name="input_http_static_ip"></a> [http\_static\_ip](#input\_http\_static\_ip) | static ip address for the http loadbalancer | `string` | n/a | yes |
| <a name="input_mqtt_static_ip"></a> [mqtt\_static\_ip](#input\_mqtt\_static\_ip) | static ip address for the mqtt loadbalancer | `string` | n/a | yes |
| <a name="input_oauth_app_name"></a> [oauth\_app\_name](#input\_oauth\_app\_name) | Name of the Application | `string` | n/a | yes |
| <a name="input_oauth_client_id"></a> [oauth\_client\_id](#input\_oauth\_client\_id) | The Google OAuth 2.0 client ID used in the Identity-Aware-Proxy (IAP) | `string` | n/a | yes |
| <a name="input_oauth_client_secret"></a> [oauth\_client\_secret](#input\_oauth\_client\_secret) | The Google OAuth 2.0 client secret used in the Identity-Aware-Proxy (IAP) | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID in which the cluster is present | `string` | n/a | yes |
| <a name="input_prometheus_adapter_custom_metrics"></a> [prometheus\_adapter\_custom\_metrics](#input\_prometheus\_adapter\_custom\_metrics) | Prometheus metrics to expose via the prometheus adapter to use as custom metrics in horizontal pod autoscaler. | `list` | <pre>[<br>  {<br>    "metricsQuery": "sum(hono_connections_authenticated{<<.LabelMatchers>>}) by (<<.GroupBy>>)",<br>    "resources": {<br>      "overrides": {<br>        "kubernetes_namespace": {<br>          "resource": "namespace"<br>        },<br>        "kubernetes_pod_name": {<br>          "resource": "pod"<br>        }<br>      }<br>    },<br>    "seriesQuery": "hono_connections_authenticated{kubernetes_namespace!=\"\",kubernetes_pod_name!=\"\"}"<br>  }<br>]</pre> | no |
| <a name="input_prometheus_adapter_version"></a> [prometheus\_adapter\_version](#input\_prometheus\_adapter\_version) | Version of the prometheus-adapter helm chart. | `string` | `"4.4.1"` | no |
| <a name="input_reloader_version"></a> [reloader\_version](#input\_reloader\_version) | Version of the stakater reloader helm chart. | `string` | `"v1.0.29"` | no |
| <a name="input_service_name_communication"></a> [service\_name\_communication](#input\_service\_name\_communication) | name of the Cloud Endpoint service for device communication | `string` | n/a | yes |
| <a name="input_sql_db_pw"></a> [sql\_db\_pw](#input\_sql\_db\_pw) | password for the sql\_user for the database | `string` | n/a | yes |
| <a name="input_sql_grafana_database"></a> [sql\_grafana\_database](#input\_sql\_grafana\_database) | Name of the postgres database for Grafana. | `string` | n/a | yes |
| <a name="input_sql_hono_database"></a> [sql\_hono\_database](#input\_sql\_hono\_database) | Name of the postgres database for Hono. | `string` | n/a | yes |
| <a name="input_sql_ip"></a> [sql\_ip](#input\_sql\_ip) | URL of the Postgres Database | `string` | n/a | yes |
| <a name="input_sql_user"></a> [sql\_user](#input\_sql\_user) | username of the sql database username | `string` | n/a | yes |
| <a name="input_ssl_policy_name"></a> [ssl\_policy\_name](#input\_ssl\_policy\_name) | Name of the SSL policy for external ingress. | `string` | n/a | yes |
| <a name="input_trust_manager_version"></a> [trust\_manager\_version](#input\_trust\_manager\_version) | Version of the chart to deploy. | `string` | `"0.5.0"` | no |
| <a name="input_wildcard_domain"></a> [wildcard\_domain](#input\_wildcard\_domain) | The wildcard domain the secret will be maintained for (e.g. *.root-domain.com). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hono_tls_crt_in_storage"></a> [hono\_tls\_crt\_in\_storage](#output\_hono\_tls\_crt\_in\_storage) | n/a |
| <a name="output_hono_tls_key_in_storage"></a> [hono\_tls\_key\_in\_storage](#output\_hono\_tls\_key\_in\_storage) | n/a |
| <a name="output_values"></a> [values](#output\_values) | n/a |
<!-- END_TF_DOCS -->
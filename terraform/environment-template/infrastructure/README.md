## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 7 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 7 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_infrastructure"></a> [infrastructure](#module\_infrastructure) | ../../infrastructure | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the GKE Cluster |
| <a name="output_gke_autopilot_enabled"></a> [gke\_autopilot\_enabled](#output\_gke\_autopilot\_enabled) | If autopilot mode is enabled for the GKE cluster. |
| <a name="output_grafana_expose_externally"></a> [grafana\_expose\_externally](#output\_grafana\_expose\_externally) | Whether or not Grafana should be exposed externally. |
| <a name="output_grafana_static_ip"></a> [grafana\_static\_ip](#output\_grafana\_static\_ip) | Output of the static IP for grafana external ingress. |
| <a name="output_grafana_static_ip_name"></a> [grafana\_static\_ip\_name](#output\_grafana\_static\_ip\_name) | Name of the static IP for grafana external ingress. |
| <a name="output_hono_api_static_ip"></a> [hono\_api\_static\_ip](#output\_hono\_api\_static\_ip) | Output of the static IP for External Ingress |
| <a name="output_hono_api_static_ip_name"></a> [hono\_api\_static\_ip\_name](#output\_hono\_api\_static\_ip\_name) | Name of the Static IP for External Ingress |
| <a name="output_http_adapter_static_ip"></a> [http\_adapter\_static\_ip](#output\_http\_adapter\_static\_ip) | Output of the http adapter static ip address. |
| <a name="output_legacy_load_balancer_setup_enabled"></a> [legacy\_load\_balancer\_setup\_enabled](#output\_legacy\_load\_balancer\_setup\_enabled) | Whether the legacy load balancer setup with Kubernetes Ingress and Cloud Endpoints should be enabled. |
| <a name="output_mqtt_adapter_static_ip"></a> [mqtt\_adapter\_static\_ip](#output\_mqtt\_adapter\_static\_ip) | Output of the mqtt adapter static ip address. |
| <a name="output_node_locations"></a> [node\_locations](#output\_node\_locations) | The zones the standard node pool will create nodes in (only applicable if cluster autopilot is disabled). IMPORTANT: The GCP Load Balancer will only create Network Endpoint Groups (NEGs) in these specified zones. Pods running in other zones will not be accessible via the load balancer. This limitation does not apply to the legacy load balancer setup ('legacy\_load\_balancer\_setup\_enabled = true'). |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | ID of the Project |
| <a name="output_region"></a> [region](#output\_region) | Region in which the Cluster will be deployed |
| <a name="output_service_name_communication"></a> [service\_name\_communication](#output\_service\_name\_communication) | Name of the Cloud Endpoints Service Device Registry |
| <a name="output_sql_db_pw"></a> [sql\_db\_pw](#output\_sql\_db\_pw) | SQL Database User Password |
| <a name="output_sql_grafana_database"></a> [sql\_grafana\_database](#output\_sql\_grafana\_database) | Name of the grafana postgres database. |
| <a name="output_sql_hono_database"></a> [sql\_hono\_database](#output\_sql\_hono\_database) | Name of the hono postgres database. |
| <a name="output_sql_ip"></a> [sql\_ip](#output\_sql\_ip) | IP of the SQL Database |
| <a name="output_sql_user"></a> [sql\_user](#output\_sql\_user) | SQL Database Username |
| <a name="output_ssl_policy"></a> [ssl\_policy](#output\_ssl\_policy) | SSL policy for external ingress |
| <a name="output_zone"></a> [zone](#output\_zone) | Zone in which the Cluster will be deployed |

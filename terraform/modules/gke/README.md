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
| [google_cloudfunctions2_function.gke_notification_email_function](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function) | resource |
| [google_container_cluster.hono_autopilot_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_cluster.hono_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.standard_node_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_storage_bucket.gke_notification_email_function_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_object.gke_notification_email_function_archive](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gke_autopilot_enabled"></a> [gke\_autopilot\_enabled](#input\_gke\_autopilot\_enabled) | If autopilot mode should be enabled for the GKE cluster. | `bool` | n/a | yes |
| <a name="input_gke_cluster_maintenance_policy_recurring_window"></a> [gke\_cluster\_maintenance\_policy\_recurring\_window](#input\_gke\_cluster\_maintenance\_policy\_recurring\_window) | The recurring window maintenance policy for the cluster. For details see: https://registry.terraform.io/providers/hashicorp/google/5.15.0/docs/resources/container_cluster#nested_maintenance_policy | <pre>object({<br/>    start_time = string,<br/>    end_time   = string,<br/>    recurrence = string<br/>  })</pre> | n/a | yes |
| <a name="input_gke_cluster_name"></a> [gke\_cluster\_name](#input\_gke\_cluster\_name) | Name of the GKE Cluster | `string` | n/a | yes |
| <a name="input_gke_enable_private_nodes"></a> [gke\_enable\_private\_nodes](#input\_gke\_enable\_private\_nodes) | Enables the private cluster configuration for the GKE cluster. | `bool` | n/a | yes |
| <a name="input_gke_machine_type"></a> [gke\_machine\_type](#input\_gke\_machine\_type) | Machine Type for node\_pools | `string` | n/a | yes |
| <a name="input_gke_node_pool_name"></a> [gke\_node\_pool\_name](#input\_gke\_node\_pool\_name) | The name of the Node Pool in the Hono Cluster | `string` | n/a | yes |
| <a name="input_gke_notification_email"></a> [gke\_notification\_email](#input\_gke\_notification\_email) | The email address of the recipients for the Google Kubernetes Engine notifications. | `string` | n/a | yes |
| <a name="input_gke_notification_enabled"></a> [gke\_notification\_enabled](#input\_gke\_notification\_enabled) | Enables notification emails for some Google Kubernetes Engine events (UPGRADE\_AVAILABLE\_EVENT, UPGRADE\_EVENT and SECURITY\_BULLETIN\_EVENT). | `bool` | n/a | yes |
| <a name="input_gke_notification_pubsub_topic"></a> [gke\_notification\_pubsub\_topic](#input\_gke\_notification\_pubsub\_topic) | The topic to which the google cluster notifications are published to. | `string` | n/a | yes |
| <a name="input_gke_release_channel"></a> [gke\_release\_channel](#input\_gke\_release\_channel) | Which Release Channel to use for the Cluster | `string` | n/a | yes |
| <a name="input_gke_service_account_email"></a> [gke\_service\_account\_email](#input\_gke\_service\_account\_email) | Email of the GKE Service Account | `string` | n/a | yes |
| <a name="input_ip_ranges_pods"></a> [ip\_ranges\_pods](#input\_ip\_ranges\_pods) | Secondary IP Ranges in Subnetwork for Pods | `string` | n/a | yes |
| <a name="input_ip_ranges_services"></a> [ip\_ranges\_services](#input\_ip\_ranges\_services) | Secondary IP Ranges in Subnetwork for Services | `string` | n/a | yes |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | name of the network | `string` | n/a | yes |
| <a name="input_node_locations"></a> [node\_locations](#input\_node\_locations) | List of Strings for the Node Locations. IMPORTANT: The GCP Load Balancer will only create Network Endpoint Groups (NEGs) in these specified zones. Pods running in other zones will not be accessible via the load balancer. This limitation does not apply to the legacy load balancer setup ('legacy\_load\_balancer\_setup\_enabled = true'). | `list(string)` | n/a | yes |
| <a name="input_node_pool_autoscaling_enabled"></a> [node\_pool\_autoscaling\_enabled](#input\_node\_pool\_autoscaling\_enabled) | If node autoscaling should be enabled | `string` | n/a | yes |
| <a name="input_node_pool_batch_node_count"></a> [node\_pool\_batch\_node\_count](#input\_node\_pool\_batch\_node\_count) | Number of nodes to drain in a batch during blue-green upgrade process | `number` | n/a | yes |
| <a name="input_node_pool_batch_soak_duration"></a> [node\_pool\_batch\_soak\_duration](#input\_node\_pool\_batch\_soak\_duration) | Duration to wait after each batch finishes draining during blue-green upgrade process | `string` | n/a | yes |
| <a name="input_node_pool_disk_size"></a> [node\_pool\_disk\_size](#input\_node\_pool\_disk\_size) | Size of the Node Pool Disk | `number` | n/a | yes |
| <a name="input_node_pool_disk_type"></a> [node\_pool\_disk\_type](#input\_node\_pool\_disk\_type) | Disk type of the Node Pool | `string` | n/a | yes |
| <a name="input_node_pool_initial_node_count"></a> [node\_pool\_initial\_node\_count](#input\_node\_pool\_initial\_node\_count) | Initial number of nodes | `number` | n/a | yes |
| <a name="input_node_pool_max_node_count"></a> [node\_pool\_max\_node\_count](#input\_node\_pool\_max\_node\_count) | Maximum number of nodes per zone | `number` | n/a | yes |
| <a name="input_node_pool_max_surge"></a> [node\_pool\_max\_surge](#input\_node\_pool\_max\_surge) | Max surge nodes during surge upgrade process | `number` | n/a | yes |
| <a name="input_node_pool_max_unavailable"></a> [node\_pool\_max\_unavailable](#input\_node\_pool\_max\_unavailable) | Max unavailable nodes during surge upgrade process | `number` | n/a | yes |
| <a name="input_node_pool_min_node_count"></a> [node\_pool\_min\_node\_count](#input\_node\_pool\_min\_node\_count) | Minimum number of nodes per zone | `number` | n/a | yes |
| <a name="input_node_pool_soak_duration"></a> [node\_pool\_soak\_duration](#input\_node\_pool\_soak\_duration) | Duration to wait after all batches are drained during blue-green upgrade process | `string` | n/a | yes |
| <a name="input_node_pool_upgrade_strategy"></a> [node\_pool\_upgrade\_strategy](#input\_node\_pool\_upgrade\_strategy) | Upgrade strategy for node pool | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to deploy to | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy to | `string` | n/a | yes |
| <a name="input_sendgrid_api_key"></a> [sendgrid\_api\_key](#input\_sendgrid\_api\_key) | The api key used to access sendgrid mail provisioner | `string` | n/a | yes |
| <a name="input_sendgrid_domain"></a> [sendgrid\_domain](#input\_sendgrid\_domain) | The domain of the sendgrid mail provisioner | `string` | n/a | yes |
| <a name="input_subnetwork_name"></a> [subnetwork\_name](#input\_subnetwork\_name) | name of the subnetwork | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gke_cluster_name"></a> [gke\_cluster\_name](#output\_gke\_cluster\_name) | Name of the GKE Cluster |

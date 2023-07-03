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
| [google_compute_address.http_static_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.mqtt_static_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_global_address.device_communication_static_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_global_address.private_ip_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network.vpc_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_ssl_policy.ssl_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_policy) | resource |
| [google_compute_subnetwork.subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_service_networking_connection.private_vpc_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_http_ip_creation"></a> [enable\_http\_ip\_creation](#input\_enable\_http\_ip\_creation) | Used to enable the creation of a static ip for the http adapter | `string` | n/a | yes |
| <a name="input_enable_mqtt_ip_creation"></a> [enable\_mqtt\_ip\_creation](#input\_enable\_mqtt\_ip\_creation) | Used to enable the creation of a static ip for the mqtt adapter | `string` | n/a | yes |
| <a name="input_ip_cidr_range"></a> [ip\_cidr\_range](#input\_ip\_cidr\_range) | The range of internal addresses that are owned by this subnetwork. Provide this property when you create the subnetwork.Ranges must be unique and non-overlapping within a network. Only IPv4 is supported. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to deploy to | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy to | `string` | n/a | yes |
| <a name="input_secondary_ip_range_pods"></a> [secondary\_ip\_range\_pods](#input\_secondary\_ip\_range\_pods) | Secondary IP Range for Pods | `string` | n/a | yes |
| <a name="input_secondary_ip_range_service"></a> [secondary\_ip\_range\_service](#input\_secondary\_ip\_range\_service) | Secondary IP Range for Services | `string` | n/a | yes |
| <a name="input_ssl_policy_min_tls_version"></a> [ssl\_policy\_min\_tls\_version](#input\_ssl\_policy\_min\_tls\_version) | The minimum TLS version the SSL policy should allow | `string` | n/a | yes |
| <a name="input_ssl_policy_name"></a> [ssl\_policy\_name](#input\_ssl\_policy\_name) | The name of the SSL policy | `string` | n/a | yes |
| <a name="input_ssl_policy_profile"></a> [ssl\_policy\_profile](#input\_ssl\_policy\_profile) | The profile of the SSL policy | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_device_communication_static_ip"></a> [device\_communication\_static\_ip](#output\_device\_communication\_static\_ip) | Output of the static IP for external ingress |
| <a name="output_device_communication_static_ip_name"></a> [device\_communication\_static\_ip\_name](#output\_device\_communication\_static\_ip\_name) | Name of the static IP for external ingress |
| <a name="output_http_static_ip"></a> [http\_static\_ip](#output\_http\_static\_ip) | Output of the http static ip address |
| <a name="output_ip_ranges_pods_name"></a> [ip\_ranges\_pods\_name](#output\_ip\_ranges\_pods\_name) | n/a |
| <a name="output_ip_ranges_services_name"></a> [ip\_ranges\_services\_name](#output\_ip\_ranges\_services\_name) | n/a |
| <a name="output_mqtt_static_ip"></a> [mqtt\_static\_ip](#output\_mqtt\_static\_ip) | Output of the mqtt static ip address |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | Output of the network id of the network that is created |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | name of the network |
| <a name="output_service_networking"></a> [service\_networking](#output\_service\_networking) | Output of the service networking connection for sql instance private IP and vpc network |
| <a name="output_ssl_policy_name"></a> [ssl\_policy\_name](#output\_ssl\_policy\_name) | Name of the SSL policy for external ingress |
| <a name="output_subnetwork_name"></a> [subnetwork\_name](#output\_subnetwork\_name) | Name ouf the subnetwork |

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_network_peering.google_network_peering](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [mongodbatlas_advanced_cluster.mongodb_cluster](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/advanced_cluster) | resource |
| [mongodbatlas_database_user.mongodb_user](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user) | resource |
| [mongodbatlas_network_container.mongodb_network_container](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/network_container) | resource |
| [mongodbatlas_network_peering.mongodb_network_peering](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/network_peering) | resource |
| [mongodbatlas_project.mongodb_project](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project) | resource |
| [mongodbatlas_project_ip_access_list.primary_ip](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list) | resource |
| [mongodbatlas_project_ip_access_list.secondary_ip_pods](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list) | resource |
| [mongodbatlas_project_ip_access_list.secondary_ip_service](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_atlas_mongodb_cluster_cidr_block"></a> [atlas\_mongodb\_cluster\_cidr\_block](#input\_atlas\_mongodb\_cluster\_cidr\_block) | Cluster CIDR Block | `string` | n/a | yes |
| <a name="input_atlas_mongodb_cluster_instance_node_count"></a> [atlas\_mongodb\_cluster\_instance\_node\_count](#input\_atlas\_mongodb\_cluster\_instance\_node\_count) | Cluster instance node count | `number` | n/a | yes |
| <a name="input_atlas_mongodb_cluster_instance_size_name"></a> [atlas\_mongodb\_cluster\_instance\_size\_name](#input\_atlas\_mongodb\_cluster\_instance\_size\_name) | Cluster instance size name | `string` | n/a | yes |
| <a name="input_atlas_mongodb_org_id"></a> [atlas\_mongodb\_org\_id](#input\_atlas\_mongodb\_org\_id) | Atlas Organization ID | `string` | n/a | yes |
| <a name="input_atlas_mongodb_project_name"></a> [atlas\_mongodb\_project\_name](#input\_atlas\_mongodb\_project\_name) | Atlas Project Name | `string` | n/a | yes |
| <a name="input_atlas_mongodb_region"></a> [atlas\_mongodb\_region](#input\_atlas\_mongodb\_region) | Atlas region where resources will be created | `string` | n/a | yes |
| <a name="input_atlas_mongodb_version"></a> [atlas\_mongodb\_version](#input\_atlas\_mongodb\_version) | MongoDB Version | `string` | n/a | yes |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | The GCP project ID to deploy to | `string` | n/a | yes |
| <a name="input_gcp_subnet_ip_cidr_range"></a> [gcp\_subnet\_ip\_cidr\_range](#input\_gcp\_subnet\_ip\_cidr\_range) | The range of internal addresses that are owned by the subnetwork of the VPC network. | `string` | n/a | yes |
| <a name="input_gcp_subnet_secondary_ip_range_pods"></a> [gcp\_subnet\_secondary\_ip\_range\_pods](#input\_gcp\_subnet\_secondary\_ip\_range\_pods) | Secondary IP Range for Pods. | `string` | n/a | yes |
| <a name="input_gcp_subnet_secondary_ip_range_service"></a> [gcp\_subnet\_secondary\_ip\_range\_service](#input\_gcp\_subnet\_secondary\_ip\_range\_service) | Secondary IP Range for Services. | `string` | n/a | yes |
| <a name="input_gcp_vpc_network_name"></a> [gcp\_vpc\_network\_name](#input\_gcp\_vpc\_network\_name) | Name of the GCP VPC network. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mongodb_cluster_connection_string"></a> [mongodb\_cluster\_connection\_string](#output\_mongodb\_cluster\_connection\_string) | Connection string for the MongoDB cluster. |
| <a name="output_mongodb_pw"></a> [mongodb\_pw](#output\_mongodb\_pw) | Output of the MongoDB user password. |
| <a name="output_mongodb_user"></a> [mongodb\_user](#output\_mongodb\_user) | Output of the MongoDB user name. |
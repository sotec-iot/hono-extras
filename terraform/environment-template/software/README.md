## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 4 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_software"></a> [software](#module\_software) | ../../software | n/a |

## Resources

| Name | Type |
|------|------|
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_container_cluster.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/container_cluster) | data source |
| [terraform_remote_state.infrastructure](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.software](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

No inputs.

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

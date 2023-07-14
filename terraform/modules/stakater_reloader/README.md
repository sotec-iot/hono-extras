## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.stakater-reloader](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hono_namespace"></a> [hono\_namespace](#input\_hono\_namespace) | Namespace of the hono deployment. | `string` | n/a | yes |
| <a name="input_reloader_version"></a> [reloader\_version](#input\_reloader\_version) | Version of the stakater reloader helm chart. | `string` | n/a | yes |

## Outputs

No outputs.
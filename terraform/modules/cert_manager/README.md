## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | ~> 1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.trust-manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.certificate](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.issuer_letsencrypt_prod](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.trust-bundle](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_secret.cert_manager_sa_key_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_manager_cert_duration"></a> [cert\_manager\_cert\_duration](#input\_cert\_manager\_cert\_duration) | Validity period of a newly created certificate (e.g. 2160h for 90 day validity). | `string` | n/a | yes |
| <a name="input_cert_manager_cert_renew_before"></a> [cert\_manager\_cert\_renew\_before](#input\_cert\_manager\_cert\_renew\_before) | When to renew the certificate based on its remaining validity period (e.g. 360h for 15 days before expiration). | `string` | n/a | yes |
| <a name="input_cert_manager_email"></a> [cert\_manager\_email](#input\_cert\_manager\_email) | E-Mail address to contact in case something goes wrong with the certificate renewal. | `string` | n/a | yes |
| <a name="input_cert_manager_issuer_kind"></a> [cert\_manager\_issuer\_kind](#input\_cert\_manager\_issuer\_kind) | Kind of the cert-manager issuer (Issuer or ClusterIssuer). | `string` | n/a | yes |
| <a name="input_cert_manager_issuer_name"></a> [cert\_manager\_issuer\_name](#input\_cert\_manager\_issuer\_name) | Name of the cert-manager issuer. | `string` | n/a | yes |
| <a name="input_cert_manager_issuer_project_id"></a> [cert\_manager\_issuer\_project\_id](#input\_cert\_manager\_issuer\_project\_id) | Project ID in which the Cloud DNS zone to manage the DNS entries is located. | `string` | n/a | yes |
| <a name="input_cert_manager_namespace"></a> [cert\_manager\_namespace](#input\_cert\_manager\_namespace) | Namespace of the cert manager deployment. | `string` | n/a | yes |
| <a name="input_cert_manager_sa_account_id"></a> [cert\_manager\_sa\_account\_id](#input\_cert\_manager\_sa\_account\_id) | Account id of the cert-manager Service Account. | `string` | n/a | yes |
| <a name="input_cert_manager_sa_key_file"></a> [cert\_manager\_sa\_key\_file](#input\_cert\_manager\_sa\_key\_file) | Service Account Key File for cert-manager Service Account. | `string` | n/a | yes |
| <a name="input_cert_manager_version"></a> [cert\_manager\_version](#input\_cert\_manager\_version) | Version of the chart to deploy. | `string` | n/a | yes |
| <a name="input_hono_domain_managed_secret_name"></a> [hono\_domain\_managed\_secret\_name](#input\_hono\_domain\_managed\_secret\_name) | Name of the kubernetes secret for the hono domain (wildcard) managed by cert-manager. | `string` | n/a | yes |
| <a name="input_hono_namespace"></a> [hono\_namespace](#input\_hono\_namespace) | Namespace of the hono deployment. | `string` | n/a | yes |
| <a name="input_hono_trust_store_config_map_name"></a> [hono\_trust\_store\_config\_map\_name](#input\_hono\_trust\_store\_config\_map\_name) | Name of the kubernetes trust store config map for the hono deployments managed by trust-manager. | `string` | n/a | yes |
| <a name="input_trust_manager_version"></a> [trust\_manager\_version](#input\_trust\_manager\_version) | Version of the chart to deploy. | `string` | n/a | yes |
| <a name="input_wildcard_domain"></a> [wildcard\_domain](#input\_wildcard\_domain) | The wildcard domain the secret will be maintained for (e.g. *.root-domain.com). | `string` | n/a | yes |

## Outputs

No outputs.

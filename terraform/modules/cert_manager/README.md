## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | ~> 1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_member.sa_binding_dns_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.trust-manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.ca-issuer](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.certificate](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.hono_internal_tls_cert](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.issuer_letsencrypt_prod](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.root-ca-certificate](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.root-issuer](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.trust-bundle](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_manager_cert_duration"></a> [cert\_manager\_cert\_duration](#input\_cert\_manager\_cert\_duration) | Validity period of a newly created certificate (e.g. 2160h for 90 day validity). | `string` | n/a | yes |
| <a name="input_cert_manager_cert_renew_before"></a> [cert\_manager\_cert\_renew\_before](#input\_cert\_manager\_cert\_renew\_before) | When to renew the certificate based on its remaining validity period (e.g. 720h for 30 days before expiration). | `string` | n/a | yes |
| <a name="input_cert_manager_email"></a> [cert\_manager\_email](#input\_cert\_manager\_email) | E-Mail address to contact in case something goes wrong with the certificate renewal. | `string` | n/a | yes |
| <a name="input_cert_manager_issuer_kind"></a> [cert\_manager\_issuer\_kind](#input\_cert\_manager\_issuer\_kind) | Kind of the cert-manager issuer (Issuer or ClusterIssuer). | `string` | n/a | yes |
| <a name="input_cert_manager_issuer_name"></a> [cert\_manager\_issuer\_name](#input\_cert\_manager\_issuer\_name) | Name of the cert-manager issuer. | `string` | n/a | yes |
| <a name="input_cert_manager_issuer_project_id"></a> [cert\_manager\_issuer\_project\_id](#input\_cert\_manager\_issuer\_project\_id) | Project ID in which the Cloud DNS zone to manage the DNS entries is located. | `string` | n/a | yes |
| <a name="input_cert_manager_namespace"></a> [cert\_manager\_namespace](#input\_cert\_manager\_namespace) | Namespace of the cert manager deployment. | `string` | n/a | yes |
| <a name="input_cert_manager_version"></a> [cert\_manager\_version](#input\_cert\_manager\_version) | Version of the chart to deploy. | `string` | n/a | yes |
| <a name="input_cluster_self_signed_issuer_name"></a> [cluster\_self\_signed\_issuer\_name](#input\_cluster\_self\_signed\_issuer\_name) | Name of the issuer used for the clusters root internal certification process, used by cert-manager. | `string` | n/a | yes |
| <a name="input_helm_release_name"></a> [helm\_release\_name](#input\_helm\_release\_name) | Name of the helm release | `string` | n/a | yes |
| <a name="input_hono_cluster_ca_issuer"></a> [hono\_cluster\_ca\_issuer](#input\_hono\_cluster\_ca\_issuer) | Name of the issuer used for the clusters application certification process, used by cert-manager. | `string` | n/a | yes |
| <a name="input_hono_cluster_ca_name"></a> [hono\_cluster\_ca\_name](#input\_hono\_cluster\_ca\_name) | Name of the clusters internal ca for hono deployments internal communication, managed by cert-manager. | `string` | n/a | yes |
| <a name="input_hono_cluster_ca_secret_name"></a> [hono\_cluster\_ca\_secret\_name](#input\_hono\_cluster\_ca\_secret\_name) | Name of the kubernetes secret containing the clusters internal ca.crt for hono deployments internal communication, managed by cert-manager. | `string` | n/a | yes |
| <a name="input_hono_domain_managed_secret_name"></a> [hono\_domain\_managed\_secret\_name](#input\_hono\_domain\_managed\_secret\_name) | Name of the kubernetes secret for the hono domain (wildcard) managed by cert-manager. | `string` | n/a | yes |
| <a name="input_hono_internal_tls_cert_name"></a> [hono\_internal\_tls\_cert\_name](#input\_hono\_internal\_tls\_cert\_name) | Name of the Certificate resource for Hono internal TLS | `string` | n/a | yes |
| <a name="input_hono_internal_tls_secret_name"></a> [hono\_internal\_tls\_secret\_name](#input\_hono\_internal\_tls\_secret\_name) | Name of the kubernetes secret that will store the Hono internal TLS certificate | `string` | n/a | yes |
| <a name="input_hono_namespace"></a> [hono\_namespace](#input\_hono\_namespace) | Namespace of the hono deployment. | `string` | n/a | yes |
| <a name="input_hono_root_domain"></a> [hono\_root\_domain](#input\_hono\_root\_domain) | The root domain of the Hono installation (e.g. hono.my-domain.com). | `string` | n/a | yes |
| <a name="input_hono_trust_store_config_map_name"></a> [hono\_trust\_store\_config\_map\_name](#input\_hono\_trust\_store\_config\_map\_name) | Name of the kubernetes trust store config map for the hono deployments managed by trust-manager. | `string` | n/a | yes |
| <a name="input_legacy_load_balancer_setup_enabled"></a> [legacy\_load\_balancer\_setup\_enabled](#input\_legacy\_load\_balancer\_setup\_enabled) | Whether or not the legacy load balancer setup with Kubernetes Ingress and Cloud Endpoints should be enabled. | `bool` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID in which the cluster is present | `string` | n/a | yes |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | Project number of the project in which the cluster is present | `string` | n/a | yes |
| <a name="input_trust_manager_version"></a> [trust\_manager\_version](#input\_trust\_manager\_version) | Version of the chart to deploy. | `string` | n/a | yes |

## Outputs

No outputs.

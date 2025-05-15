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
| [google_monitoring_alert_policy.k8s_critical_cpu_usage_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.k8s_critical_memory_usage_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.k8s_readiness_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.pod_restart_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_notification_channel.google_chat_channel](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_notification_channel) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alerts_chat_space_id"></a> [alerts\_chat\_space\_id](#input\_alerts\_chat\_space\_id) | The Chat space ID is the string following “chat/space/” in the chat URL. It can only be seen in the web view of the Chat app. In order to add Google Chat as a notification channel, you must first add the Google Cloud Monitoring App to the chat space. You can add the app directly to a space by typing @Google Cloud Monitoring. | `string` | n/a | yes |
| <a name="input_cert_manager_namespace"></a> [cert\_manager\_namespace](#input\_cert\_manager\_namespace) | Namespace of the cert manager deployment. | `string` | n/a | yes |
| <a name="input_hono_namespace"></a> [hono\_namespace](#input\_hono\_namespace) | namespace of the deployment | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to deploy to | `string` | n/a | yes |

## Outputs

No outputs.

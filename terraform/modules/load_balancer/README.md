## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.load-balancer](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map.tcp](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_load_balancer"></a> [advanced\_load\_balancer](#input\_advanced\_load\_balancer) | Configuration options for the advanced MQTT load balancer.<br>  chart\_version: Version of the chart to deploy.<br>  replicaCount: Number of replicas to deploy.<br>  port\_configs: List of MQTT port config objects for the advanced MQTT load balancer service.<br>  tcp\_configmap\_data: Data of the TCP configMap for the advanced MQTT load balancer. | <pre>object({<br>    chart_version = string,<br>    replicaCount = number,<br>    port_configs = list(object({<br>      name       = string,<br>      port       = number,<br>      targetPort = number<br>    })),<br>    tcp_configmap_data = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_hono_namespace"></a> [hono\_namespace](#input\_hono\_namespace) | Namespace of the Hono deployment. | `string` | n/a | yes |
| <a name="input_mqtt_static_ip"></a> [mqtt\_static\_ip](#input\_mqtt\_static\_ip) | Static ip address for the MQTT loadbalancer. | `string` | n/a | yes |

## Outputs

No outputs.
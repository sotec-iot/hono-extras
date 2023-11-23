variable "hono_namespace" {
  type        = string
  description = "Namespace of the Hono deployment."
}

variable "mqtt_static_ip" {
  type        = string
  description = "Static ip address for the MQTT loadbalancer."
}

variable "advanced_load_balancer" {
  type        = object({
    chart_version = string,
    replicaCount = number,
    port_configs = list(object({
      name       = string,
      port       = number,
      targetPort = number
    })),
    tcp_configmap_data = map(string)
  })
  description = <<EOT
Configuration options for the advanced MQTT load balancer.
  chart_version: Version of the chart to deploy.
  replicaCount: Number of replicas to deploy.
  port_configs: List of MQTT port config objects for the advanced MQTT load balancer service.
  tcp_configmap_data: Data of the TCP configMap for the advanced MQTT load balancer.
EOT
}

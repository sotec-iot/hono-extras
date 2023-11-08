variable "hono_namespace" {
  type        = string
  description = "Namespace of the Hono deployment."
}

variable "enable_mqtt_adapter" {
  type        = bool
  description = "Used to enable the MQTT adapter."
}

variable "mqtt_static_ip" {
  type        = string
  description = "Static ip address for the MQTT loadbalancer."
}

variable "enhanced_mqtt_load_balancer" {
  type = object({
    chart_version = string
    replicaCount = number
    port_configs = list(object({
      name       = string,
      port       = number,
      targetPort = number
    }))
    tcp_configmap_data = map(string)
  })
  description = <<EOT
Configuration options for the enhanced MQTT load balancer.
  chart_version: Version of the chart to deploy.
  replicaCount: Number of replicas to deploy.
  port_configs: List of MQTT port config objects for the enhanced MQTT load balancer service.
  tcp_configmap_data: Data of the TCP configMap for the enhanced MQTT load balancer.
EOT
}
resource "google_monitoring_notification_channel" "google_chat_channel" {
  display_name = "Hono alerts chat"
  type         = "google_chat"
  lifecycle {
    precondition {
      condition     = var.alerts_chat_space_id != "" && var.alerts_chat_space_id != null
      error_message = "alerts_chat_space_id must be set to enable alerts"
    }
  }
  labels = {
    space = "spaces/${var.alerts_chat_space_id}"
  }
  force_delete = false
}

resource "google_monitoring_alert_policy" "k8s_critical_cpu_usage_alert_policy" {
  display_name          = "High CPU usage in pod"
  notification_channels = [google_monitoring_notification_channel.google_chat_channel.id]

  combiner = "OR"
  conditions {
    display_name = "Pod cpu request utilization over 85%"
    condition_prometheus_query_language {
      query               = "max by (container_name) (avg_over_time(kubernetes_io:container_cpu_request_utilization{monitored_resource=\"k8s_container\", project_id=\"${var.project_id}\", namespace_name=~\"${var.hono_namespace}|${var.cert_manager_namespace}\"}[5m])) > 0.85"
      duration            = "300s"
      evaluation_interval = "30s"
    }
  }

  alert_strategy {
    notification_channel_strategy {
      renotify_interval = "3600s"
    }
  }
  severity = "WARNING"
  project  = var.project_id
  documentation {
    subject = "${var.project_id}: High pod CPU usage"
    content = "Pod is using more than 85% of requested CPU."
  }
}


resource "google_monitoring_alert_policy" "k8s_critical_memory_usage_policy" {
  display_name          = "High memory usage in pod"
  notification_channels = [google_monitoring_notification_channel.google_chat_channel.id]

  combiner = "OR"
  conditions {
    display_name = "Pod is using more than 90% of its memory limit"
    condition_prometheus_query_language {
      # compare memory usage to memory limit over the last minute, exclude containers without limit, and select pods that use more than 85% of their memory limit
      query               = "max by (container_name) (avg_over_time(kubernetes_io:container_memory_used_bytes{monitored_resource=\"k8s_container\", project_id=\"${var.project_id}\", namespace_name=~\"${var.hono_namespace}|${var.cert_manager_namespace}\", memory_type=\"non-evictable\"}[1m])) / max by (container_name) (max_over_time(kubernetes_io:container_memory_request_bytes{monitored_resource=\"k8s_container\", project_id=\"${var.project_id}\", namespace_name=~\"${var.hono_namespace}|${var.cert_manager_namespace}\"}[1m]) > 0) > 0.9"
      duration            = "300s"
      evaluation_interval = "30s"
    }
  }

  alert_strategy {
    notification_channel_strategy {
      renotify_interval = "3600s"
    }
  }
  severity = "WARNING"
  project  = var.project_id
  documentation {
    subject = "${var.project_id}: High memory usage by pod"
    content = "Pod uses more than 90% of its requested memory limit."
  }
}


resource "google_monitoring_alert_policy" "k8s_readiness_alert_policy" {
  display_name          = "K8s readiness failures alert"
  notification_channels = [google_monitoring_notification_channel.google_chat_channel.id]

  combiner = "OR"
  conditions {
    display_name = "Pod readiness failure alert"
    condition_prometheus_query_language {
      query               = "max by (pod) (avg_over_time(kube_pod_status_phase{project_id=\"${var.project_id}\",namespace=~\"${var.hono_namespace}|${var.cert_manager_namespace}\", phase!=\"Running\", phase!=\"Succeeded\", pod!=\"\"}[1m])) > 0.9"
      duration            = "60s"
      evaluation_interval = "30s"
    }
  }

  alert_strategy {
    notification_channel_strategy {
      renotify_interval = "3600s"
    }
  }
  severity = "WARNING"
  project  = var.project_id
  documentation {
    subject = "${var.project_id}: Pod not ready alert"
    content = "The pod was observed to be not ready in the last minute"
  }
}

resource "google_monitoring_alert_policy" "pod_restart_alert_policy" {
  display_name          = "One or more pod restarts in last 5 mins"
  notification_channels = [google_monitoring_notification_channel.google_chat_channel.id]

  combiner = "OR"
  conditions {
    display_name = "One or more pod restarts in last 5 mins"
    condition_prometheus_query_language {
      # Value is 0/1 depending if the pod is in the specified phase
      query               = "sum by (container_name) (increase(kubernetes_io:container_restart_count{monitored_resource=\"k8s_container\",project_id=\"${var.project_id}\",namespace_name=~\"${var.hono_namespace}|${var.cert_manager_namespace}\"}[5m])) > 0"
      duration            = "300s" # 5 min
      evaluation_interval = "30s"
    }
  }

  alert_strategy {
    notification_channel_strategy {
      renotify_interval = "3600s"
    }
  }
  severity = "WARNING"
  project  = var.project_id
  documentation {
    subject = "${var.project_id}: Pod restart in last 5 mins"
    content = "${var.project_id}: Pod restart detected."
  }
}

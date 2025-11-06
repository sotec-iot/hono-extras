locals {
  project_id          = "<project_id>"                                         # Insert your project id
  region              = "europe-west1"                                         # Insert the region for your cluster
  zone                = "europe-west1-b"                                       # Insert the zone for your cluster and SQL database
  node_locations      = ["europe-west1-c", "europe-west1-b", "europe-west1-d"] # Insert the node locations for your cluster. IMPORTANT: The GCP Load Balancer will only create Network Endpoint Groups (NEGs) in these specified zones. Pods running in other zones will not be accessible via the load balancer. This limitation does not apply to the legacy load balancer setup ('legacy_load_balancer_setup_enabled = true').
}

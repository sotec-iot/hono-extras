module "infrastructure" {
  source = "../../infrastructure"
  
  project_id          = local.project_id
  region              = local.region
  node_locations      = local.node_locations
  enable_cert_manager = local.enable_cert_manager
}

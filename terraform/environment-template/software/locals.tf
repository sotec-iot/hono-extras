locals {
  bucket_name                   = "<bucket_name>"             # Insert the name of the storage bucket
  oauth_app_name                = "<oauth_app_name>"          # Insert the name of your OAuth application
  hono_root_domain              = "<hono_root_domain>"        # Insert your Hono root domain (e.g. hono.my-domain.com)
  hono_api_host_address         = "<api_host_address>"        # Insert the host address of your Hono API (e.g. hono.my-domain.com or api.hono.my-domain.com). Must be the Hono root domain or a direct subdomain of it
  oauth_client_id               = "<oauth_client_id>"         # Insert the client ID of your OAuth 2.0 client
  oauth_client_secret           = "<oauth_client_secret>"     # Insert the client secret of your OAuth 2.0 client
  helm_package_repository       = "<helm_package_repository>" # Insert the link to your helm chart (e.g. oci://europe-west1-docker.pkg.dev/my-project/my-repository)
  hono_chart_name               = "<chart_name>"              # Insert the name of your helm chart (e.g. hono)
  hono_chart_version            = "<chart_version>"           # Insert the version of your helm chart (e.g. 2.5.0-1)
  enable_cert_manager           = false                       # Toggle the use of the cert-manager

  # The following variable only has to be set if enable_cert_manager is set to true!
  cert_manager_email = "<email>"           # Insert an E-Mail address to contact in case something goes wrong with the certificate renewal
}

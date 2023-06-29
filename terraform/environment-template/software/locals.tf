locals {
  bucket_name                   = "<bucket_name>"                             # Insert the name of the storage bucket
  oauth_app_name                = "<oauth-app_name>"                          # Insert the name of your OAuth application
  device_communication_dns_name = "<dns_name>"                                # Insert the name of your API DNS (e.g. api.hono.my-domain.com)
  oauth_client_id               = "<oauth_client_id>"                         # Insert the client ID of your OAuth 2.0 client
  oauth_client_secret           = "<oauth_client_secret>"                     # Insert the client secret of your OAuth 2.0 client
  helm_package_repository       = "<helm-package-repository>"                 # Insert the link to your helm chart (e.g. oci://europe-west1-docker.pkg.dev/my-project/my-repository)
  hono_chart_name               = "<chart-name>"                              # Insert the name of your helm chart (e.g. hono)

  # To create or change the kubernetes secrets please provide the private keys and certificates with the respective names inside the same folder as this file for the secrets you want to create.
  #
  # File names:
  #   For api secret:
  #     api_tls.key
  #     api_tls.crt
  #   For http adapter secret:
  #     http_tls.key
  #     http_tls.crt
  #   For mqtt adapter secret:
  #     mqtt_tls.key
  #     mqtt_tls.crt
  #
  # note: this is only needed to create a secret or to change it. Otherwise the key and certificate can be omitted.
}

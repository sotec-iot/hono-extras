locals {
  bucket_name                   = "<bucket_name>"                             # Insert the name of the storage bucket
  oauth_app_name                = "<oauth-app_name>"                          # Insert the name of your OAuth application
  device_communication_dns_name = "<dns_name>"                                # Insert the name of your API DNS (e.g. api.hono.my-domain.com)
  oauth_client_id               = "<oauth_client_id>"                         # Insert the client ID of your OAuth 2.0 client
  oauth_client_secret           = "<oauth_client_secret>"                     # Insert the client secret of your OAuth 2.0 client
  helm_package_repository       = "<helm-package-repository>"                 # Insert the link to your helm chart (e.g. oci://europe-west1-docker.pkg.dev/my-project/my-repository)
  hono_chart_name               = "<chart-name>"                              # Insert the name of your helm chart (e.g. hono)

  enable_cert_manager           = false                                       # Toggle the use of the cert-manager

  # In case enable_cert_manager is set to false:
  #
  # To create or change the hono domain kubernetes secret (wildcard certificate, e.g. *.my-domain.com) please provide the private key and certificate with the respective names inside the same folder as this file.
  #
  # File names:
  #   hono_tls.key
  #   hono_tls.crt
  #
  # note: this is only needed to create the secret or to change it. Otherwise the key and certificate can be omitted.

  # The following variable only have to be given values if enable_cert_manager is set to true!
  cert_manager_email            = "<email>"                                   # Insert an E-Mail address to contact in case something goes wrong with the certificate renewal
  wildcard_domain               = "<wildcard-domain>"                         # Insert your root domain with a wildcard character as a sub domain (e.g. *.my-domain.com)
}

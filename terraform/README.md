# Hono Terraform Deployment

Use the environment-template to deploy Eclipse-Hono in a project.

Prerequisites:
1. Register a domain name. For instructions about how to register a domain using Cloud Domains, see [Register a domain](https://cloud.google.com/dns/docs/tutorials/create-domain-tutorial).
2. Set up your [OAuth Consent Screen](https://console.cloud.google.com/apis/credentials/consent). More information about [OAuth Consent Screen](https://support.google.com/cloud/answer/10311615?hl=en&ref_topic=3473162&sjid=5743182626460156348-EU).
3. Create an [OAuth Client](https://console.cloud.google.com/apis/credentials).
4. Create a Cloud Storage bucket, see [Create buckets](https://cloud.google.com/storage/docs/creating-buckets).


The following steps need to be followed:
1. Replace the placeholders in the following files with the name of the newly created bucket:
    * backend.tf in environment-template/infrastructure,
    * backend.tf and locals.tf in environment-template/software.
2. Adjust the values in the locals.tf files in environment-template/infrastructure and environment-template/software to fit your case.
3. Open a command-line interface (CLI).
4. Set your project in your gcloud config by running the following command:
    ```
    gcloud config set project project-id
    ```
    Replace <b>project-id</b> with the ID of your project.
5. Log into your account by running:
    ```
    gcloud auth application-default login
    ```
6. Within your CLI navigate to the environment-template/infrastructure folder and run the following commands:
    ```
    terraform init
    ```
    ```
    terraform plan
    ```
    ```
    terraform apply
    ```
7. Setup DNS records for the Eclipse Hono API & MQTT endpoint (Example: api.hono.my-domain.com and mqtt.hono.my-domain.com) with the static IPs you get as an output from the terraform apply. For instructions on how to set up DNS records in Google Cloud DNS, see [Setup DNS records](https://cloud.google.com/dns/docs/set-up-dns-records-domain-name).
8. Next you have to decide if you want to use [cert-manager](https://cert-manager.io) or manage the TLS certificate manually.
   1. Using cert-manager:
      1. Make sure the DNS records are set up in [Google Cloud DNS](https://console.cloud.google.com/net-services/dns).
      2. Enable the cert-manager in locals.tf in environment-template/software and provide a contact E-Mail and the root domain of the DNS records with a wildcard character (e.g. *.my-domain.com)
   2. Manual Certificate management:
      1. Create a wildcard certificate for the DNS records (e.g. *.my-domain.com). For example use [letsencrypt](https://letsencrypt.org).
      2. Rename the certificate and key to "hono_tls.crt" and "hono_tls.key", respectively, and move them into the folder environment-template/software.
9. Add the URI of the DNS record for the Eclipse Hono API/UI to the Authorized redirect URIs within your [OAuth Client](https://console.cloud.google.com/apis/credentials).
10. Navigate to the environment-template/software folder within your CLI.
11. Register gcloud as a Docker credential helper by running:
    ```
    gcloud auth configure-docker location-docker.pkg.dev
    ```
    Replace <b>location</b> with the location of the Artifact Registry, where the Helm chart is located.
12. If your Helm chart is within a private Artifact Registry:

    Authenticate with the registry using the following command:

    Linux/macOS:
    ```
    gcloud auth application-default print-access-token | helm registry login -u oauth2accesstoken --password-stdin https://location-docker.pkg.dev
    ```
    Windows:
    ```
    gcloud auth application-default print-access-token
    ```
    returns: ya29.8QEQIfY_...
    ```
    helm registry login -u oauth2accesstoken -p ya29.8QEQIfY_… https://location-docker.pkg.dev
    ```
    
    Replace <b>location</b> with the location of the Artifact Registry, where the Helm chart is located.
13. Run the following commands again:
    ```
    terraform init
    ```
    ```
    terraform plan
    ```
    ```
    terraform apply
    ```


More Details to Variables and Locals can be found in the template README´s

## Customizing the deployment further

To see a full list of variables that can be changed to customize the deployment see:

Infrastructure part: [https://github.com/sotec-iot/hono-extras/blob/terraform/terraform/infrastructure/variables.tf](https://github.com/sotec-iot/hono-extras/blob/terraform/terraform/software/variables.tf)<br/>
Software part: [https://github.com/sotec-iot/hono-extras/blob/terraform/terraform/software/variables.tf](https://github.com/sotec-iot/hono-extras/blob/terraform/terraform/software/variables.tf)

### Changing a variable
To change the value of a variable, e.g. grafana_expose_externally, add the variable in the corresponding locals.tf file and assign it a new value.<br/>
For our example:
```
grafana_expose_externally = true
```
Now go to the corresponding main.tf file and add the following line
```
VARIABLE = local.VARIABLE
```
Replace `VARIABLE` with the name of the variable you want to change.<br/>
For our example:
```
grafana_expose_externally = local.grafana_expose_externally
```

### Changing an object variable
To change the properties within a variable of type object you have to follow the same steps as for a simple variable (described above) except you have to provide an object in the locals.tf file.
For object variables that have optional properties you can just provide the non-optional properties and the ones you want to change.<br/>
So for example the properties of `chart_version` and `algorithm` within the variable `enhanced_mqtt_load_balancer` can be change like seen below:
```
enhanced_mqtt_load_balancer = {chart_version = "1.0.0", algorithm = "roundrobin"}
```
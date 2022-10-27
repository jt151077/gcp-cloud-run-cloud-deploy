# Cloud Run with Cloud Deploy
Simple Cloud Run deployment pipeline using Terraform, CloudBuild, CloudDeploy, Artifact Registry and Cloud Run to deploy a simple web site from a docker container in GCP.

Source for the Skaffold configuration: [https://cloud.google.com/deploy/docs/deploy-app-run](https://cloud.google.com/deploy/docs/deploy-app-run)

Source for HTTP(S) Load Balancer with Cloud Run: [https://cloud.google.com/load-balancing/docs/https/ext-http-lb-tf-module-examples#with_a_backend](https://cloud.google.com/load-balancing/docs/https/ext-http-lb-tf-module-examples#with_a_backend)


## Overall architecture

![](imgs/13.png)


## Project structure
```

.
├── app (web application based on nginx)
│   ├── Dockerfile
│   └── index.html
├── cloudbuild.yaml (build sequence for Cloud Build)
├── clouddeploy.yaml (delivery pipeline for Cloud Deploy )
├── config.tf (services and provider)
├── deploy.sh (deploy script using gcloud command)
├── gcr.tf (managed artifact repository)
├── iam.tf (service accounts and roles)
├── install.sh (install script for gcp api using gcloud command)
├── network.tf (LoadBalancer and IAP)
├── README.md
├── run-dev.yaml (cloud run service dev)
├── run-prod.yaml (cloud run service prod)
├── skaffold.yaml (scaffold file for Cloud Deploy)
├── terraform.tfvars.json (local env variables for terraform)
├── uninstall.sh (uninstall script using gcloud command)
└── vars.tf (variables configuration)

```

## Setup

1. Find out your GCP project's id and number from the dashboard in the cloud console, and run the following commands in a terminal at the root of source code (replace `your_project_number`, `your_project_id` and `your_project_region` by the correct values). The `your_iap_email` needs be part of your organisation, and in this example is both the support email for the IAP brand and the user allowed to access the Cloud Run prod service. Create an A record under your Cloud DNS and use this as `your_domain`.
```shell
find . -type f -not -path '*/\.*' -exec sed -i 's/190578371855/your_project_number/g' {} +
find . -type f -not -path '*/\.*' -exec sed -i 's/cloud-run-deploy-iap-20221026/your_project_id/g' {} +
find . -type f -not -path '*/\.*' -exec sed -i 's/europe-west1/your_project_region/g' {} +
find . -type f -not -path '*/\.*' -exec sed -i 's/jeremy@jeremyto.altostrat.com/your_iap_email/g' {} +
find . -type f -not -path '*/\.*' -exec sed -i 's/cloudrun.jeremyto.demo.altostrat.com/your_domain/g' {} +
```

## Install

1. Run the following command at the root of the folder:
```shell 
$ sudo ./install.sh
$ terraform init
$ terraform plan
$ terraform apply
```

> Note: You may have to run `terraform plan` and `terraform apply` twice if you get errors for serviceaccounts not found

2. Build and deploy the webserver image in GKE, by issuing the following command at the root of the project:

```shell
$ ./deploy.sh
```

> This will build a docker image using Cloud Build, and create a release in Cloud Deploy

![](imgs/0.png)

![](imgs/1.png)

> This will then deploy the dev image to Cloud Run using Cloud Deploy

![](imgs/2.png)

> Selecting the deployed Cloud Run service, it gives access to the exposed URL

![](imgs/3.png)

> Opening this in a browser, shows a 403 error

![](imgs/4.png)


3. Run the following command at the root of the project

```shell 
gcloud run services add-iam-policy-binding deploy-qs-dev --member="allUsers" --role="roles/run.invoker" --project="<your_project_id>" --region="<your_project_region>"
```

> This now allows unauthenticated access to the service

![](imgs/5.png)

> Opening the same URL in a browser, it should show the following:

![](imgs/6.png)



4. Back in Cloud Deploy, click on "promote" for the dev release

![](imgs/1.png)

> Click again on "promote" at the bottom of the side panel:

![](imgs/7.png)

> After a short while, it Cloud Deploy deploys a release in production

![](imgs/8.png)

> This, as a result, has deployed the same docker image as a production Cloud Run service

![](imgs/9.png)


3. From the `terraform apply` output, cope the `external_ip` address and set it as the IPv4 address on your DNS A record.

4. Open an web borwser window and go to `your_domain`

![](imgs/14.png)

5. After login in with your `your_iap_email`

> it should show the following:

![](imgs/11.png)




## Uninstall


1. Run the following at the root of your project

```shell 
$ ./uninstall.sh
```

> All resources will now be removed from your project
> Note IAP brand cannot be deleted via Terraform

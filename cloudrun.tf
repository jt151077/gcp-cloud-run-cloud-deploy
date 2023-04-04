/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  cloud_run_environments = [
    "deploy-qs-dev",
    "deploy-qs-prod"
  ]
}

resource "google_cloud_run_service" "run-environments" {
  count = length(local.cloud_run_environments)

  depends_on = [
    google_project_service.gcp_services
  ]

  name     = local.cloud_run_environments[count.index]
  project  = local.project_id
  location = local.project_default_region

  template {
    spec {
      containers {
        image = "nginx:latest"

        ports {
          container_port = 80
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].spec[0].service_account_name
    ]
  }
}

resource "google_cloud_run_service_iam_binding" "run-environments-binding" {
  count = length(local.cloud_run_environments)

  depends_on = [
    google_project_service.gcp_services,
    module.lb-http,
    google_cloud_run_service.run-environments
  ]
  project  = local.project_id
  location = local.project_default_region
  service  = local.cloud_run_environments[count.index]
  role     = "roles/run.invoker"
  members = [
    "allUsers",
  ]
}

resource "google_iap_web_backend_service_iam_binding" "binding" {
  depends_on = [
    google_project_service.gcp_services,
    module.lb-http
  ]
  project             = local.project_id
  web_backend_service = nonsensitive(values(module.lb-http.backend_services).*.name)[0]
  role                = "roles/iap.httpsResourceAccessor"
  members             = local.iap_authorised_users
}

resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
  depends_on = [
    google_project_service.gcp_services
  ]

  name                  = "cloud-run-neg"
  network_endpoint_type = "SERVERLESS"
  region                = local.project_default_region
  project               = local.project_id
  cloud_run {
    service = "deploy-qs-prod"
  }
}

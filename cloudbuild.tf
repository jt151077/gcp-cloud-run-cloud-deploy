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

resource "google_cloudbuild_trigger" "deploy-from-github" {
  depends_on = [
    google_project_service.gcp_services
  ]


  project     = local.project_id
  name        = "build-from-github"
  description = "Build artifcats from Github"
  filename    = "cloudbuild.yaml"

  #service_account = google_service_account.cloudbuild_service_account.id

  github {
    name  = "gcp-cloud-run-cloud-deploy"
    owner = "jt151077"
    push {
      branch = "master"
    }
  }
}
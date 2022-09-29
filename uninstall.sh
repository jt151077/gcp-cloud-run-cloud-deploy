#!/bin/bash

echo 'Destroying all resources'

gcloud deploy delete --file clouddeploy.yaml --force --region PROJECT_REGION --project PROJECT_ID
gcloud run services delete deploy-qs-dev --region PROJECT_REGION --project PROJECT_ID
gcloud run services delete deploy-qs-prod --region PROJECT_REGION --project PROJECT_ID
terraform apply -destroy -auto-approve
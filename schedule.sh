#!/bin/bash

set -e

if [ -z ${DEVICE_ID} ]; then
  echo "DEVICE_ID is required"
  exit 1
fi

if [ -z ${ACCESS_TOKEN} ]; then
  echo "ACCESS_TOKEN is required"
  exit 1
fi

# delete all existing jobs
gcloud beta scheduler jobs list  --project home-automation-311014 | tail -n +2 | \
  while read -r jobname _; do
    gcloud beta scheduler jobs delete $jobname --quiet --project home-automation-311014
  done

PROJECT=home-automation-311014
TIMEZONE=Europe/Berlin

gcloud beta scheduler jobs create http back-on-every-hour --schedule="0 8-21/3 * * *" \
  --uri="https://api.particle.io/v1/devices/$DEVICE_ID/zone_back" \
  --headers="Authorization=Bearer $ACCESS_TOKEN,Content-Type=application/x-www-form-urlencoded" \
  --message-body="args=on" \
  --http-method=POST \
  --project $PROJECT \
  --time-zone $TIMEZONE

gcloud beta scheduler jobs create http back-off-every-hour --schedule="1 8-21/3 * * *" \
  --uri="https://api.particle.io/v1/devices/$DEVICE_ID/zone_back" \
  --headers="Authorization=Bearer $ACCESS_TOKEN,Content-Type=application/x-www-form-urlencoded" \
  --message-body="args=off" \
  --http-method=POST \
  --project $PROJECT \
  --time-zone $TIMEZONE

gcloud beta scheduler jobs create http side-on-every-hour --schedule="2 8-21/3 * * *" \
  --uri="https://api.particle.io/v1/devices/$DEVICE_ID/zone_side" \
  --headers="Authorization=Bearer $ACCESS_TOKEN,Content-Type=application/x-www-form-urlencoded" \
  --message-body="args=on" \
  --http-method=POST \
  --project $PROJECT \
  --time-zone $TIMEZONE

gcloud beta scheduler jobs create http side-off-every-hour --schedule="3 8-21/3 * * *" \
  --uri="https://api.particle.io/v1/devices/$DEVICE_ID/zone_side" \
  --headers="Authorization=Bearer $ACCESS_TOKEN,Content-Type=application/x-www-form-urlencoded" \
  --message-body="args=off" \
  --http-method=POST \
  --project $PROJECT \
  --time-zone $TIMEZONE

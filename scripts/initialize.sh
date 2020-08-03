#!/bin/bash
SCRIPT_DIR=$(dirname $(realpath "$0"))
cd "$SCRIPT_DIR/.."

if [ "$1" != "" ]; then
  PROJECT_ID="$1"
else
  echo "$0 projectId"
  exit 1
fi

gcloud --project="${PROJECT_ID}" services enable run.googleapis.com containerregistry.googleapis.com

gcloud --project="${PROJECT_ID}" app deploy helloworld-jdk-server/target/helloworld.jar

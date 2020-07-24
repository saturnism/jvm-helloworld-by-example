#!/bin/bash
SCRIPT_DIR=$(dirname $(realpath "$0"))
cd "$SCRIPT_DIR/.."

if [ "$1" != "" ]; then
  PROJECT_ID="$1"
else
  echo "$0 projectId [module]"
  exit 1
fi

REPORT_DIR="$SCRIPT_DIR/../reports"
#rm -rf "$REPORT_DIR"
mkdir -p $REPORT_DIR

function service_name {
  local module="$1"
  prefix="helloworld-"
  echo ${module#$prefix};
}

function loadtest_url {
  local url="$1"
  local report_file="$2"

  hey -c 100 -n 1000 -t 0 -disable-keepalive -o csv "$url" > "$report_file"
}

function loadtest_appengine {
  local project_id=$1
  local service_name=$2

  local url=$(gcloud app browse --service="$service_name" --project="$project_id" --no-launch-browser)
  echo "- $url"

  local report_file="$REPORT_DIR/appengine-$service_name"
  loadtest_url "$url" "${report_file}.txt"

  gcloud logging read --project="$project_id" "log_name=\"projects/${project_id}/logs/stdout\" resource.type=\"gae_app\" resource.labels.module_id=\"${service_name}\" textPayload =~ \".*Started .*\"" \
     --format='value(textPayload)' --limit=100 > "${report_file}.log"

}

function loadtest_cloudrun {
  local project_id=$1
  local region=$2
  local service_name=$3

  local url=$(gcloud run services describe "$service_name" --region="$region" --project="$project_id" --platform=managed --format='value(status.address.url)')
  echo "- $url"

  local report_file="$REPORT_DIR/cloudrun-$service_name"
  loadtest_url "$url" "${report_file}.txt"
  gcloud logging read --project="$project_id" "log_name=\"projects/${project_id}/logs/run.googleapis.com%2Fstdout\" resource.type=\"cloud_run_revision\" resource.labels.service_name=\"${service_name}\" textPayload =~ \".*Started .*\"" \
     --format='value(textPayload)' --limit=100 > "${report_file}.log"
}

function loadtest_appengine_variations {
  local project_id="$1"
  local module="$2"
  local service_name=$(service_name "$module")

  echo "Load Test to App Engine, F1"
  loadtest_appengine "$project_id" "${service_name}"

  echo "Load Test to App Engine, F2"
  loadtest_appengine "$project_id" "${service_name}-f2"

  echo "Load Test to App Engine, F1, Tiered Compliation"
  loadtest_appengine "$project_id" "${service_name}-tc"

  echo "Load Test to App Engine, F2, Tiered Compliation"
  loadtest_appengine "$project_id" "${service_name}-tc-f2"

  echo "Load Test to App Engine, F1, Lazy Init"
  loadtest_appengine "$project_id" "${service_name}-lazy"

  echo "Load Test to App Engine, F2, Lazy Init"
  loadtest_appengine "$project_id" "${service_name}-lazy-f2"

  echo "Load Test to App Engine, F1, Lazy Init, Tiered Compliation"
  loadtest_appengine "$project_id" "${service_name}-lazy-tc"

  echo "Load Test to App Engine, F2, Lazy Init, Tiered Compliation"
  loadtest_appengine "$project_id" "${service_name}-lazy-tc-f2"
}

function loadtest_cloudrun_variations {
  local project_id="$1"
  local module="$2"
  local service_name=$(service_name "$module")

  echo "Load Test Jib image to Cloud Run, 1CPU"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-jib"

  echo "Load Test Jib image to Cloud Run, 2CPU"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-jib-2cpu"

  echo "Load Test Jib image to Cloud Run, 1CPU, Tiered Compliation"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-jib-tc"

  echo "Load Test Jib image to Cloud Run, 2CPU, Tiered Compliation"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-jib-tc-2cpu"

  echo "Load Test Jib image to Cloud Run, 1CPU, Lazy Init"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-jib-lazy"

  echo "Load Test Jib image to Cloud Run, 2CPU, Lazy Init"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-jib-lazy-2cpu"

  echo "Load Test Jib image to Cloud Run, 1CPU, Lazy Init, Tiered Compliation"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-jib-lazy-tc"

  echo "Load Test Jib image to Cloud Run, 2CPU, Lazy Init, Tiered Compliation"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-jib-lazy-tc-2cpu"

  echo "Load Test Docker image to Cloud Run, 1CPU"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker"

  echo "Load Test Docker image to Cloud Run, 2CPU"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-2cpu"

  echo "Load Test Docker image to Cloud Run, 1CPU, Tiered Compliation"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-tc"

  echo "Load Test Docker image to Cloud Run, 2CPU, Tiered Compliation"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-tc-2cpu"

  echo "Load Test Docker image to Cloud Run, 1CPU, Lazy Init"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-lazy"

  echo "Load Test Docker image to Cloud Run, 2CPU, Lazy Init"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-lazy-2cpu"

  echo "Load Test Docker image to Cloud Run, 1CPU, Lazy Init, Tiered Compliation"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-lazy-tc"

  echo "Load Test Docker image to Cloud Run, 2CPU, Lazy Init, Tiered Compliation"
  loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-lazy-tc-2cpu"

  
  if [ -f "$module/.appcds" ]; then
    echo "Load Test Docker image to Cloud Run, 1CPU, AppCDS"
    loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds"

    echo "Load Test Docker image to Cloud Run, 2CPU, AppCDS"
    loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-2cpu"

    echo "Load Test Docker image to Cloud Run, 1CPU, AppCDS, Lazy Init"
    loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-lazy"

    echo "Load Test Docker image to Cloud Run, 2CPU, AppCDS, Lazy Init"
    loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-lazy-2cpu"

    echo "Load Test Docker image to Cloud Run, 1CPU, AppCDS, Tiered Compliation"
    loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-tc"

    echo "Load Test Docker image to Cloud Run, 2CPU, AppCDS, Tiered Compliation"
    loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-tc-2cpu"

    echo "Load Test Docker image to Cloud Run, 1CPU, AppCDS, Lazy Init, Tiered Compliation"
    loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-lazy-tc"

    echo "Load Test Docker image to Cloud Run, 2CPU, AppCDS, Lazy Init, Tiered Compliation"
    loadtest_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-lazy-tc-2cpu"
  fi
}

function loadtest_module {
  local project_id="$1"
  local module="$2"

  loadtest_appengine_variations "$project_id" "$module"
  loadtest_cloudrun_variations "$project_id" "$module"
}

echo "Delete Cloud Logging Logs"
gcloud logging logs delete -q --project="$PROJECT_ID" "projects/$PROJECT_ID/logs/stdout"
gcloud logging logs delete -q --project="$PROJECT_ID" "projects/$PROJECT_ID/logs/run.googleapis.com%2Fstdout"

if [ "$2" != "" ]; then
  loadtest_module "$PROJECT_ID" "$2"
else
  mvn --also-make dependency:tree | grep maven-dependency-plugin | awk '{ print $(NF-1) }' | grep -v parent | while read module; do
    loadtest_module "$PROJECT_ID" "$module"
  done
fi



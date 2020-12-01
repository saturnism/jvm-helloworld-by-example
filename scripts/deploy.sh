#!/bin/bash
SCRIPT_DIR=$(dirname $(realpath "$0"))
cd "$SCRIPT_DIR/.."
REPORT_DIR="$SCRIPT_DIR/../reports"
mkdir -p "$REPORT_DIR"

if [ "$1" != "" ]; then
  PROJECT_ID="$1"
else
  echo "$0 projectId [module]"
  exit 1
fi

TIERED_COMPILIATON_FLAGS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
APPCDS_FLAGS="-Xshare:on -XX:SharedArchiveFile=appcds.jsa"
LAZY_INIT_FLAGS="-Dspring.main.lazy-initialization=true"

function service_name {
  local module="$1"
  prefix="helloworld-"
  echo ${module#$prefix};
}

function deploy_appengine {
  local project_id=$1
  local service_name=$2
  local instance_class=$3
  local jar=$4
  local java_tool_options=$5

  local appyaml_file=$(mktemp /tmp/app.yaml.XXXXXX)

  cat "$SCRIPT_DIR/app.yaml.tmpl" | \
  service_name="$service_name" instance_class="$instance_class" java_tool_options="$java_tool_options" \
    envsubst > $appyaml_file

  local report_file="$REPORT_DIR/appengine-$service_name.time"
  {
    time gcloud -q --project="$project_id" app deploy "$jar" --appyaml="$appyaml_file" -v=1 2>&1
  } 2>"$report_file"

  rm $appyaml_file
}

function deploy_cloudrun {
  local project_id=$1
  local region=$2
  local service_name=$3
  local image=$4
  local cpus=$5
  local memory=$6
  local java_tool_options=$7

  local report_file="$REPORT_DIR/cloudrun-$service_name.time"

  {
    time gcloud -q --project="$project_id" run deploy "$service_name" --region="$region" --image="$image" --set-env-vars="JAVA_TOOL_OPTIONS=${java_tool_options}" --platform managed --allow-unauthenticated 2>&1
  } 2>"$report_file"
}

function deploy_appengine_variations {
  local project_id="$1"
  local module="$2"
  local service_name=$(service_name "$module")

  echo "Deploy to App Engine, F1"
  deploy_appengine "$project_id" "${service_name}" "F1" "${module}/target/helloworld.jar" ""

  echo "Deploy to App Engine, F2"
  deploy_appengine "$project_id" "${service_name}-f2" "F2" "${module}/target/helloworld.jar" ""

  echo "Deploy to App Engine, F1, Tiered Compliation"
  deploy_appengine "$project_id" "${service_name}-tc" "F1" "${module}/target/helloworld.jar" "${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy to App Engine, F2, Tiered Compliation"
  deploy_appengine "$project_id" "${service_name}-tc-f2" "F2" "${module}/target/helloworld.jar" "${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy to App Engine, F1, Lazy Init"
  deploy_appengine "$project_id" "${service_name}-lazy" "F1" "${module}/target/helloworld.jar" "${LAZY_INIT_FLAGS}"

  echo "Deploy to App Engine, F2, Lazy Init"
  deploy_appengine "$project_id" "${service_name}-lazy-f2" "F2" "${module}/target/helloworld.jar" "${LAZY_INIT_FLAGS}"

  echo "Deploy to App Engine, F1, Lazy Init, Tiered Compliation"
  deploy_appengine "$project_id" "${service_name}-lazy-tc" "F1" "${module}/target/helloworld.jar" "${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"

  echo "Deploy to App Engine, F2, Lazy Init, Tiered Compliation"
  deploy_appengine "$project_id" "${service_name}-lazy-tc-f2" "F2" "${module}/target/helloworld.jar" "${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"


}

function deploy_cloudrun_variations {
  local project_id="$1"
  local module="$2"

  local image_prefix="gcr.io/${project_id}"

  local image_name="${image_prefix}/${module}-jib"
  local service_name=$(service_name "$module")

  echo "Deploy Jib image to Cloud Run, 1CPU"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-jib" "${image_name}" "1" "256M" ""

  echo "Deploy Jib image to Cloud Run, 2CPU"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-jib-2cpu" "${image_name}" "2" "256M" ""

  echo "Deploy Jib image to Cloud Run, 1CPU, Tiered Compliation"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-jib-tc" "${image_name}" "1" "256M" "${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy Jib image to Cloud Run, 2CPU, Tiered Compliation"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-jib-tc-2cpu" "${image_name}" "2" "256M" "${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy Jib image to Cloud Run, 1CPU, Lazy Init"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-jib-lazy" "${image_name}" "1" "256M" "${LAZY_INIT_FLAGS}"

  echo "Deploy Jib image to Cloud Run, 2CPU, Lazy Init"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-jib-lazy-2cpu" "${image_name}" "2" "256M" "${LAZY_INIT_FLAGS}"

  echo "Deploy Jib image to Cloud Run, 1CPU, Lazy Init, Tiered Compliation"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-jib-lazy-tc" "${image_name}" "1" "256M" "${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"

  echo "Deploy Jib image to Cloud Run, 2CPU, Lazy Init, Tiered Compliation"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-jib-lazy-tc-2cpu" "${image_name}" "2" "256M" "${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"

  local image_name="${image_prefix}/${module}-docker"

  echo "Deploy Docker image to Cloud Run, 1CPU"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker" "${image_name}" "1" "256M" ""

  echo "Deploy Docker image to Cloud Run, 2CPU"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-2cpu" "${image_name}" "2" "256M" ""

  echo "Deploy Docker image to Cloud Run, 1CPU, Tiered Compliation"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-tc" "${image_name}" "1" "256M" "${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 2CPU, Tiered Compliation"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-tc-2cpu" "${image_name}" "2" "256M" "${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 1CPU, Lazy Init"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-lazy" "${image_name}" "1" "256M" "${LAZY_INIT_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 2CPU, Lazy Init"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-lazy-2cpu" "${image_name}" "2" "256M" "${LAZY_INIT_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 1CPU, Lazy Init, Tiered Compliation"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-lazy-tc" "${image_name}" "1" "256M" "${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 2CPU, Lazy Init, Tiered Compliation"
  deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-lazy-tc-2cpu" "${image_name}" "2" "256M" "${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"

  
  if [ -f "$module/.appcds" ]; then
    echo "Deploy Docker image to Cloud Run, 1CPU, AppCDS"
    deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds" "${image_name}" "1" "256M" "${APPCDS_FLAGS}"

    echo "Deploy Docker image to Cloud Run, 2CPU, AppCDS"
    deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-2cpu" "${image_name}" "2" "256M" "${APPCDS_FLAGS}"

    echo "Deploy Docker image to Cloud Run, 1CPU, AppCDS, Lazy Init"
    deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-lazy" "${image_name}" "1" "256M" "${APPCDS_FLAGS} ${LAZY_INIT_FLAGS}"

    echo "Deploy Docker image to Cloud Run, 2CPU, AppCDS, Lazy Init"
    deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-lazy-2cpu" "${image_name}" "2" "256M" "${APPCDS_FLAGS} ${LAZY_INIT_FLAGS}"

    echo "Deploy Docker image to Cloud Run, 1CPU, AppCDS, Tiered Compliation"
    deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-tc" "${image_name}" "1" "256M" "${APPCDS_FLAGS} ${TIERED_COMPILIATON_FLAGS}"

    echo "Deploy Docker image to Cloud Run, 2CPU, AppCDS, Tiered Compliation"
    deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-tc-2cpu" "${image_name}" "2" "256M" "${APPCDS_FLAGS} ${TIERED_COMPILIATON_FLAGS}"

    echo "Deploy Docker image to Cloud Run, 1CPU, AppCDS, Lazy Init, Tiered Compliation"
    deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-lazy-tc" "${image_name}" "1" "256M" "${APPCDS_FLAGS} ${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"

    echo "Deploy Docker image to Cloud Run, 2CPU, AppCDS, Lazy Init, Tiered Compliation"
    deploy_cloudrun "$project_id" "us-central1" "${service_name}-docker-appcds-lazy-tc-2cpu" "${image_name}" "2" "256M" "${APPCDS_FLAGS} ${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"
  fi
}

function deploy_module {
  local project_id="$1"
  local module="$2"

  mvn -pl "$module" package -DskipTests
  deploy_appengine_variations "$project_id" "$module"
  deploy_cloudrun_variations "$project_id" "$module"
}

if [ "$2" != "" ]; then
  deploy_module "$PROJECT_ID" "$2"
else
  mvn -B --also-make dependency:tree | grep maven-dependency-plugin | awk '{ print $(NF-1) }' | grep -v parent | while read module; do
    deploy_module "$PROJECT_ID" "$module"
  done
fi



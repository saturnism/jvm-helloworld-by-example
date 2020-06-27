#!/bin/bash

SCRIPT_DIR=$(dirname $(realpath "$0"))
cd "$SCRIPT_DIR"

function deploy_appengine {
  project_id=$1
  service_name=$2
  instance_class=$3
  jar=$4
  java_tool_options=$5

  appyaml_file=$(mktemp /tmp/app.yaml.XXXXXX)

  cat "$SCRIPT_DIR/app.yaml.tmpl" | \
  service_name="$service_name" instance_class="$instance_class" java_tool_options="$java_tool_options" \
  envsubst > $appyaml_file

  gcloud -q --project="$project_id" app deploy "$jar" --appyaml="$appyaml_file" -v 1

  rm $appyaml_file

}

function deploy_cloudrun {
  project_id=$1
  region=$2
  service_name=$3
  image=$4
  cpus=$5
  memory=$6
  java_tool_options=$7

  echo gcloud -q --project="$project_id" run deploy "$service_name" --region="$region" --image="$image" --set-env-vars="JAVA_TOOL_OPTIONS=${java_tool_options}" --platform managed --allow-unauthenticated
}

if [ "$1" != "" ]; then
  PROJECT_ID="$1"
else
  echo "$0 [project id]"
  exit 1
fi

IMAGE_PREFIX="gcr.io/${PROJECT_ID}"

TIERED_COMPILIATON_FLAGS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
APPCDS_FLAGS="-Xshare:on -XX:SharedArchiveFile=appcds.jsa"
LAZY_INIT_FLAGS="-Dspring.main.lazy-initialization=true"

cd ..
mvn --also-make dependency:tree | grep maven-dependency-plugin | awk '{ print $(NF-1) }' | grep -v parent | while read module; do

  mvn -pl "$module" package -DskipTests


  echo "Deploy to App Engine, F1"
  deploy_appengine "$PROJECT_ID" "${module}" "F1" "${module}/target/helloworld.jar" ""

  echo "Deploy to App Engine, F2"
  deploy_appengine "$PROJECT_ID" "${module}" "F2" "${module}/target/helloworld.jar" ""

  echo "Deploy to App Engine, F1, Tiered Compliation"
  deploy_appengine "$PROJECT_ID" "${module}-tc" "F1" "${module}/target/helloworld.jar" "${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy to App Engine, F2, Tiered Compliation"
  deploy_appengine "$PROJECT_ID" "${module}-tc" "F2" "${module}/target/helloworld.jar" "${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy to App Engine, F1, Lazy Init"
  deploy_appengine "$PROJECT_ID" "${module}-lazy" "F1" "${module}/target/helloworld.jar" "${LAZY_INIT_FLAGS}"

  echo "Deploy to App Engine, F2, Lazy Init"
  deploy_appengine "$PROJECT_ID" "${module}-lazy" "F2" "${module}/target/helloworld.jar" "${LAZY_INIT_FLAGS}"

  echo "Deploy to App Engine, F1, Lazy Init, Tiered Compliation"
  deploy_appengine "$PROJECT_ID" "${module}-lazy-tc" "F1" "${module}/target/helloworld.jar" "${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"

  echo "Deploy to App Engine, F2, Lazy Init, Tiered Compliation"
  deploy_appengine "$PROJECT_ID" "${module}-lazy-tc" "F2" "${module}/target/helloworld.jar" "${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"

  image_name="${IMAGE_PREFIX}/${module}-jib"

  echo "Deploy Jib image to Cloud Run, 1CPU"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-jib" "${image_name}" "1" "256M" ""

  echo "Deploy Jib image to Cloud Run, 2CPU"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-jib" "${image_name}" "2" "256M" ""

  echo "Deploy Jib image to Cloud Run, 1CPU, Tiered Compliation"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-jib-tc" "${image_name}" "1" "256M" "${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy Jib image to Cloud Run, 2CPU, Tiered Compliation"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-jib-tc" "${image_name}" "2" "256M" "${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy Jib image to Cloud Run, 1CPU, Lazy Init"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-jib-lazy" "${image_name}" "1" "256M" "${LAZY_INIT_FLAGS}"

  echo "Deploy Jib image to Cloud Run, 2CPU, Lazy Init"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-jib-lazy" "${image_name}" "2" "256M" "${LAZY_INIT_FLAGS}"

  echo "Deploy Jib image to Cloud Run, 1CPU, Lazy Init, Tiered Compliation"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-jib-lazy-tc" "${image_name}" "1" "256M" "${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"

  echo "Deploy Jib image to Cloud Run, 2CPU, Lazy Init, Tiered Compliation"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-jib-lazy-tc" "${image_name}" "2" "256M" "${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"


  image_name="${IMAGE_PREFIX}/${module}-docker"

  echo "Deploy Docker image to Cloud Run, 1CPU"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker" "${image_name}" "1" "256M" ""

  echo "Deploy Docker image to Cloud Run, 2CPU"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker" "${image_name}" "2" "256M" ""

  echo "Deploy Docker image to Cloud Run, 1CPU, Tiered Compliation"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-tc" "${image_name}" "1" "256M" "${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 2CPU, Tiered Compliation"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-tc" "${image_name}" "2" "256M" "${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 1CPU, Lazy Init"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-lazy" "${image_name}" "1" "256M" "${LAZY_INIT_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 2CPU, Lazy Init"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-lazy" "${image_name}" "2" "256M" "${LAZY_INIT_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 1CPU, Lazy Init, Tiered Compliation"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-lazy-tc" "${image_name}" "1" "256M" "${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 2CPU, Lazy Init, Tiered Compliation"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-lazy-tc" "${image_name}" "2" "256M" "${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 1CPU, AppCDS"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-appcds" "${image_name}" "1" "256M" "${APPCDS_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 2CPU, AppCDS"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-appcds" "${image_name}" "2" "256M" "${APPCDS_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 1CPU, AppCDS, Lazy Init"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-appcds-lazy" "${image_name}" "1" "256M" "${APPCDS_FLAGS} ${LAZY_INIT_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 2CPU, AppCDS, Lazy Init"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-appcds-lazy" "${image_name}" "2" "256M" "${APPCDS_FLAGS} ${LAZY_INIT_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 1CPU, AppCDS, Tiered Compliation"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-appcds-tc" "${image_name}" "1" "256M" "${APPCDS_FLAGS} ${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 2CPU, AppCDS, Tiered Compliation"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-appcds-tc" "${image_name}" "2" "256M" "${APPCDS_FLAGS} ${TIERED_COMPILIATON_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 1CPU, AppCDS, Lazy Init, Tiered Compliation"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-appcds-lazy-tc" "${image_name}" "1" "256M" "${APPCDS_FLAGS} ${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"

  echo "Deploy Docker image to Cloud Run, 2CPU, AppCDS, Lazy Init, Tiered Compliation"
  deploy_cloudrun "$PROJECT_ID" "us-central1" "${module}-docker-appcds-lazy-tc" "${image_name}" "2" "256M" "${APPCDS_FLAGS} ${TIERED_COMPILIATON_FLAGS} ${LAZY_INIT_FLAGS}"
done



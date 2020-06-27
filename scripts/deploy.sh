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

  image_name="${IMAGE_PREFIX}/${module}-docker"

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

  echo "Deploy to Cloud Run, 1CPU"
  echo "Deploy to Cloud Run, 2CPU"

  echo "Deploy to Cloud Run, 1CPU, Tiered Compliation"
  echo "Deploy to Cloud Run, 2CPU, Tiered Compliation"

  echo "Deploy to Cloud Run, 1CPU, Lazy Init"
  echo "Deploy to Cloud Run, 2CPU, Lazy Init"

  echo "Deploy to Cloud Run, 1CPU, Lazy Init, Tiered Compliation"
  echo "Deploy to Cloud Run, 2CPU, Lazy Init, Tiered Compliation"

  echo "Deploy to Cloud Run, 1CPU, AppCDS"
  echo "Deploy to Cloud Run, 2CPU, AppCDS"

  echo "Deploy to Cloud Run, 1CPU, AppCDS, Lazy Init"
  echo "Deploy to Cloud Run, 2CPU, AppCDS, Lazy Init"

  echo "Deploy to Cloud Run, 1CPU, AppCDS, Tiered Compliation"
  echo "Deploy to Cloud Run, 2CPU, AppCDS, Tiered Compliation"

  echo "Deploy to Cloud Run, 1CPU, AppCDS, Lazy Init, Tiered Compliation"
  echo "Deploy to Cloud Run, 2CPU, AppCDS, Lazy Init, Tiered Compliation"
done



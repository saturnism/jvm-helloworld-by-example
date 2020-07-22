#!/bin/bash

cd "$(dirname "$0")"
cd ..

if [ "$1" != "" ]; then
  PROJECT_ID=$1
else
  echo "$0 projectId [module]"
  exit 1
fi

function containerize {
  local project_id=$1
  local module=$2
  local image_prefix="gcr.io/${PROJECT_ID}"

  pushd $module

  mvn -DskipTests package

  echo "Build with Docker"
  docker build -t "${image_prefix}/${module}-docker" .
  docker push "${image_prefix}/${module}-docker"

  if [[ "$module" == *"springboot-"* ]]; then
    echo "Build with Spring Boot Buildpack"
    mvn -DskipTests spring-boot:build-image \
      -Dspring-boot.build-image.imageName="${image_prefix}/${module}-buildpack"
    docker push "${image_prefix}/${module}-buildpack"

    echo "Build with GCP Buildpack"
    mvn -DskipTests spring-boot:build-image \
      -Dspring-boot.build-image.builder=gcr.io/buildpacks/builder \
      -Dspring-boot.build-image.imageName="${image_prefix}/${module}-buildpack-gcp"
    docker push "${image_prefix}/${module}-buildpack-gcp"
  fi

  echo "Build with Jib"
  mvn -DskipTests compile com.google.cloud.tools:jib-maven-plugin:2.4.0:build \
    -Dimage="${image_prefix}/${module}-jib"

  popd
}

if [ "$2" != "" ]; then
  echo "Containerize module $2"
  containerize $PROJECT_ID $2
else
  echo "Containerize all modules..."
  mvn --also-make dependency:tree | grep maven-dependency-plugin | awk '{ print $(NF-1) }' | grep -v parent | while read module; do
    containerize $PROJECT_ID $module
  done
fi


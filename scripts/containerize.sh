#!/bin/bash

if [ "$1" != "" ]; then
  PROJECT_ID=$1
else
  echo "$0 [project id]"
  exit 1
fi

IMAGE_PREFIX="gcr.io/${PROJECT_ID}"

cd "$(dirname "$0")"
cd ..

mvn --also-make dependency:tree | grep maven-dependency-plugin | awk '{ print $(NF-1) }' | grep -v parent | while read module; do
  pushd $module

  docker build -t "${IMAGE_PREFIX}/${module}-docker" .
  docker push "${IMAGE_PREFIX}/${module}-docker"

  mvn -DskipTests compile com.google.cloud.tools:jib-maven-plugin:2.4.0:build -Dimage="${IMAGE_PREFIX}/${module}-jib"

  popd
done




#!/bin/bash

cd "$(dirname "$0")"
cd ../

mvn clean package -DskipTests

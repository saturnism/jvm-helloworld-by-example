This example builds a simple Spring Boot application, but with a shaded archive instead
of a regular Spring Boot nested JARs.

This allows Spring Boot to take advantage of AppCDS.

## Build
```
mvn package
```

## Run
```
java -jar target/helloworld-springboot-tomcat-shaded-0.0.1-SNAPSHOT.jar
```

## Containerize with Jib
```
mvn compile com.google.cloud.tools:jib-maven-plugin:2.4.0:build -Dimage=gcr.io/PROJECT_ID/helloworld-springboot-tomcat-shaded-jib
```

## Containerize with Cloud Build
```
gcloud builds submit -t gcr.io/PROJECT_ID/helloworld-springboot-tomcat-shaded-cloudbuild
```

## Docker Build with AppCDS
```
mvn package
docker build -t gcr.io/PROJECT_ID/helloworld-springboot-tomcat-shaded-docker .
```

Run without AppCDS:
```
docker run -ti --rm gcr.io/PROJECT_ID/helloworld-springboot-tomcat-shaded-docker
```

Run with AppCDS
```
docker run -ti --rm -e JAVA_TOOL_OPTIONS="-Xshare:on -XX:SharedArchiveFile=appcds.jsa" \
  gcr.io/PROJECT_ID/helloworld-springboot-tomcat-shaded-docker
```

## App Engine

```
gcloud app deploy target/helloworld-springboot-tomcat-shaded-0.0.1-SNAPSHOT.jar 
```

## Cloud Run

*Change the <IMAGE_NAME> according with your compilation mode*

* *gcr.io/PROJECT_ID/helloworld-springboot-tomcat-shaded-jib*
* *gcr.io/PROJECT_ID/helloworld-springboot-tomcat-shaded-docker*
* *gcr.io/PROJECT_ID/helloworld-springboot-tomcat-shaded-cloudbuild*


Run without AppCDS
```
gcloud run deploy helloworld-springboot-tomcat-shaded-docker \
  --image=<IMAGE_NAME> \
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```

Run without AppCDS, with Tiered compilation
```
gcloud run deploy helloworld-springboot-tomcat-shaded-docker-t1 \
  --image=<IMAGE_NAME> \
  --set-env-vars=JAVA_TOOL_OPTIONS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```


Run with AppCDS
```
gcloud run deploy helloworld-springboot-tomcat-shaded \
  --image=<IMAGE_NAME> \
  --set-env-vars=JAVA_TOOL_OPTIONS="-Xshare:on -XX:SharedArchiveFile=appcds.jsa"
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```

Run with AppCDS, with Tiered compilation
```
gcloud run deploy helloworld-springboot-tomcat-shaded \
  --image=<IMAGE_NAME> \
  --set-env-vars=JAVA_TOOL_OPTIONS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Xshare:on -XX:SharedArchiveFile=appcds.jsa"
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```

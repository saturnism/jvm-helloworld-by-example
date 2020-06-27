This example builds a simple Spring Boot application, but with a shaded archive instead
of a regular Spring Boot nested JARs.

This allows Spring Boot to take advantage of AppCDS.

## Build
```
mvn package
```

## Run
```
java -jar target/helloworld.jar
```

## Containerize with Jib
```
mvn compile com.google.cloud.tools:jib-maven-plugin:2.4.0:build -Dimage=gcr.io/PROJECT_ID/helloworld-springboot-webflux-shaded-jib
```

## Docker Build with AppCDS
```
mvn package
docker build -t gcr.io/PROJECT_ID/helloworld-springboot-webflux-shaded-docker .
```

Run without AppCDS:
```
docker run -ti --rm gcr.io/PROJECT_ID/helloworld-springboot-webflux-shaded-docker
```

Run with AppCDS
```
docker run -ti --rm -e JAVA_TOOL_OPTIONS="-Xshare:on -XX:SharedArchiveFile=appcds.jsa" \
  gcr.io/PROJECT_ID/helloworld-springboot-webflux-shaded-docker
```

## App Engine

```
gcloud app deploy target/helloworld.jar 
```

## Cloud Run
Run with Jib
```
gcloud run deploy helloworld-springboot-webflux-shaded-jib \
  --image=gcr.io/PROJECT_ID/helloworld-springboot-webflux-shaded-jib \
   --region=us-central1 \
   --platform managed \
   --allow-unauthenticated
```

Run with Docker Image, without AppCDS
```
gcloud run deploy helloworld-springboot-webflux-shaded-docker \
  --image=gcr.io/PROJECT_ID/helloworld-springboot-webflux-shaded \
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```

Run with Docker Image, without AppCDS, with Tiered compilation
```
gcloud run deploy helloworld-springboot-webflux-shaded-docker-t1 \
  --image=gcr.io/PROJECT_ID/helloworld-springboot-webflux-shaded \
  -e JAVA_TOOL_OPTIONS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```


Run with Docker Image, with AppCDS
```
gcloud run deploy helloworld-springboot-webflux-shaded \
  --image=gcr.io/PROJECT_ID/helloworld-springboot-webflux-shaded-docker \
  -e JAVA_TOOL_OPTIONS="-Xshare:on -XX:SharedArchiveFile=appcds.jsa"
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```

Run with Docker Image, with AppCDS, with Tiered compilation
```
gcloud run deploy helloworld-springboot-webflux-shaded \
  --image=gcr.io/PROJECT_ID/helloworld-springboot-webflux-shaded-docker-t1 \
  -e JAVA_TOOL_OPTIONS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Xshare:on -XX:SharedArchiveFile=appcds.jsa"
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```

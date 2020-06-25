This is a regular Spring Boot application using Webflux.

## Build
```
mvn package
```

## Run
```
java -jar target/helloworld-springboot-webflux-0.0.1-SNAPSHOT.jar
```

## Containerize with Jib
```
mvn compile com.google.cloud.tools:jib-maven-plugin:2.4.0:build -Dimage=gcr.io/PROJECT_ID/helloworld-springboot-webflux-jib
```

## Docker Build 
```
mvn package
docker build -t gcr.io/PROJECT_ID/helloworld-springboot-webflux-docker
```

Run without AppCDS:
```
docker run -ti --rm gcr.io/PROJECT_ID/helloworld-springboot-webflux-docker
```

## App Engine

```
gcloud app deploy target/helloworld-springboot-webflux-0.0.1-SNAPSHOT.jar 
```

## Cloud Run
Run with Jib
```
gcloud run deploy helloworld-springboot-webflux-jib \
  --image=gcr.io/PROJECT_ID/helloworld-springboot-webflux-jib \
   --region=us-central1 \
   --platform managed \
   --allow-unauthenticated
```

Run with Docker Image, without AppCDS
```
gcloud run deploy helloworld-springboot-webflux-docker \
  --image=gcr.io/PROJECT_ID/helloworld-springboot-webflux \
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```

Run with Docker Image, without AppCDS, with Tiered compilation
```
gcloud run deploy helloworld-springboot-webflux-docker-t1 \
  --image=gcr.io/PROJECT_ID/helloworld-springboot-webflux \
  -e JAVA_TOOL_OPTIONS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```


## Build
```
mvn package
```

## Run
```
java -jar target/helloworld-springboot-shaded-1.0-SNAPSHOT.jar
```

## Containerize with Jib
```
mvn compile com.google.cloud.tools:jib-maven-plugin:2.4.0:build -Dimage=gcr.io/PROJECT_ID/helloworld-springboot-shaded-jib
```

## Docker Build with AppCDS
```
mvn package
docker build -t gcr.io/PROJECT_ID/helloworld-springboot-shaded-appcds .
```

Run without AppCDS:
```
docker run -ti --rm gcr.io/PROJECT_ID/helloworld-springboot-shaded-appcds
```

Run with AppCDS
```
docker run -ti --rm -e JAVA_TOOL_OPTIONS="-Xshare:on -XX:SharedArchiveFile=appcds.jsa" \
  gcr.io/PROJECT_ID/helloworld-springboot-shaded-appcds
```

## App Engine

```
gcloud app deploy target/helloworld-springboot-shaded-1.0-SNAPSHOT.jar 
```

## Cloud Run
Run with Jib
```
gcloud run deploy helloworld-springboot-shaded-jib \
  --image=gcr.io/PROJECT_ID/helloworld-springboot-shaded-jib \
   --region=us-central1 \
   --platform managed \
   --allow-unauthenticated
```

Run with Docker Image, without AppCDS
```
gcloud run deploy helloworld-springboot-shaded-docker \
  --image=gcr.io/PROJECT_ID/helloworld-springboot-shaded \
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```

Run with Docker Image, without AppCDS, with Tiered compilation
```
gcloud run deploy helloworld-springboot-shaded-docker-t1 \
  --image=gcr.io/PROJECT_ID/helloworld-springboot-shaded \
  -e JAVA_TOOL_OPTIONS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```


Run with Docker Image, with AppCDS
```
gcloud run deploy helloworld-springboot-shaded \
  --image=gcr.io/PROJECT_ID/helloworld-springboot-shaded-appcds \
  -e JAVA_TOOL_OPTIONS="-Xshare:on -XX:SharedArchiveFile=appcds.jsa"
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```

Run with Docker Image, with AppCDS, with Tiered compilation
```
gcloud run deploy helloworld-springboot-shaded \
  --image=gcr.io/PROJECT_ID/helloworld-springboot-shaded-appcds-t1 \
  -e JAVA_TOOL_OPTIONS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Xshare:on -XX:SharedArchiveFile=appcds.jsa"
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```

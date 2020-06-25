This is probably the smallest Helloworld with the fastest startup, using Http Server from the
JDK.

## Build
```
mvn package
```

## Run
```
java -jar target/helloworld-jdk-server-1.0-SNAPSHOT.jar
```

## Containerize with Jib
```
mvn compile com.google.cloud.tools:jib-maven-plugin:2.4.0:build -Dimage=gcr.io/PROJECT_ID/helloworld-jdk-server-jib
```

## Docker Build with AppCDS
```
mvn package
docker build -t gcr.io/PROJECT_ID/helloworld-jdk-server-docker .
```

Run without AppCDS:
```
docker run -ti --rm gcr.io/PROJECT_ID/helloworld-jdk-server-docker
```

Run with AppCDS
```
docker run -ti --rm -e JAVA_TOOL_OPTIONS="-Xshare:on -XX:SharedArchiveFile=appcds.jsa" \
  gcr.io/PROJECT_ID/helloworld-jdk-server-docker
```

## App Engine

```
gcloud app deploy target/helloworld-jdk-server-1.0-SNAPSHOT.jar 
```

## Cloud Run
Run with Jib
```
gcloud run deploy helloworld-jdk-server-jib \
  --image=gcr.io/PROJECT_ID/helloworld-jdk-server-jib \
   --region=us-central1 \
   --platform managed \
   --allow-unauthenticated
```

Run with Docker Image, without AppCDS
```
gcloud run deploy helloworld-jdk-server-docker \
  --image=gcr.io/PROJECT_ID/helloworld-jdk-server \
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```

Run with Docker Image, without AppCDS, with Tiered compilation
```
gcloud run deploy helloworld-jdk-server-docker-t1 \
  --image=gcr.io/PROJECT_ID/helloworld-jdk-server \
  -e JAVA_TOOL_OPTIONS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```


Run with Docker Image, with AppCDS
```
gcloud run deploy helloworld-jdk-server \
  --image=gcr.io/PROJECT_ID/helloworld-jdk-server-docker \
  -e JAVA_TOOL_OPTIONS="-Xshare:on -XX:SharedArchiveFile=appcds.jsa"
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```

Run with Docker Image, with AppCDS, with Tiered compilation
```
gcloud run deploy helloworld-jdk-server \
  --image=gcr.io/PROJECT_ID/helloworld-jdk-server-docker-t1 \
  -e JAVA_TOOL_OPTIONS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Xshare:on -XX:SharedArchiveFile=appcds.jsa"
  --region=us-central1 \
  --platform managed \
  --allow-unauthenticated
```

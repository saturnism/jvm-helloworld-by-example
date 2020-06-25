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
mvn compile com.google.cloud.tools:jib-maven-plugin:2.4.0:build -Dimage=gcr.io/PROJECT_ID/helloworld-jdk-server
```

## Docker Build with AppCDS
```
mvn package
docker build -t gcr.io/PROJECT_ID/helloworld-jdk-server-appcds .
```

### AppCDS
Regular image doesn't run with AppCDS, to run with AppCDS:
```
docker run -ti --rm -e JAVA_TOOL_OPTIONS="-Xshare:on -XX:SharedArchiveFile=appcds.jsa" \
  gcr.io/PROJECT_ID/helloworld-jdk-server-appcds
```

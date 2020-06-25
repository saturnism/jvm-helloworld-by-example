FROM adoptopenjdk:11-jre-hotspot as APPCDS

COPY target/helloworld-0.0.1-SNAPSHOT.jar /helloworld-0.0.1-SNAPSHOT.jar
RUN java -XX:DumpLoadedClassList=classes.lst -jar helloworld-0.0.1-SNAPSHOT.jar --appcds=true
RUN java -Xshare:dump -XX:SharedClassListFile=classes.lst -XX:SharedArchiveFile=appcds.jsa --class-path helloworld-0.0.1-SNAPSHOT.jar

FROM adoptopenjdk:11-jre-hotspot

COPY --from=APPCDS /helloworld-0.0.1-SNAPSHOT.jar /helloworld-0.0.1-SNAPSHOT.jar
COPY --from=APPCDS /appcds.jsa /appcds.jsa

#ENTRYPOINT java -Xshare:on -XX:SharedArchiveFile=appcds.jsa -jar helloworld-0.0.1-SNAPSHOT.jar
ENTRYPOINT java -jar helloworld-0.0.1-SNAPSHOT.jar

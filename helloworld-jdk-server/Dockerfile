FROM adoptopenjdk:11-jre-hotspot as APPCDS

COPY target/helloworld.jar /helloworld.jar
RUN EXIT_IMMEDIATELY=true java -XX:DumpLoadedClassList=classes.lst -jar helloworld.jar
RUN java -Xshare:dump -XX:SharedClassListFile=classes.lst -XX:SharedArchiveFile=appcds.jsa --class-path helloworld.jar

FROM adoptopenjdk:11-jre-hotspot

COPY --from=APPCDS /helloworld.jar /helloworld.jar
COPY --from=APPCDS /appcds.jsa /appcds.jsa

ENTRYPOINT java -jar helloworld.jar

FROM adoptopenjdk:11-jre-hotspot as APPCDS

COPY target/helloworld.jar /helloworld.jar
RUN java -XX:DumpLoadedClassList=classes.lst -jar helloworld.jar --appcds=true
RUN java -Xshare:dump -XX:SharedClassListFile=classes.lst -XX:SharedArchiveFile=appcds.jsa --class-path helloworld.jar

FROM adoptopenjdk:11-jre-hotspot

COPY --from=APPCDS /helloworld.jar /helloworld.jar
COPY --from=APPCDS /appcds.jsa /appcds.jsa

#ENTRYPOINT java -Xshare:on -XX:SharedArchiveFile=appcds.jsa -jar helloworld.jar
ENTRYPOINT java -jar helloworld.jar

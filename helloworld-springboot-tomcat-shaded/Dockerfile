FROM adoptopenjdk:11-jre-hotspot as APPCDS

COPY target/helloworld-springboot-tomcat-shaded-0.0.1-SNAPSHOT.jar /helloworld-springboot-tomcat-shaded-0.0.1-SNAPSHOT.jar
RUN java -XX:DumpLoadedClassList=classes.lst -jar helloworld-springboot-tomcat-shaded-0.0.1-SNAPSHOT.jar --appcds=true
RUN java -Xshare:dump -XX:SharedClassListFile=classes.lst -XX:SharedArchiveFile=appcds.jsa --class-path helloworld-springboot-tomcat-shaded-0.0.1-SNAPSHOT.jar

FROM adoptopenjdk:11-jre-hotspot

COPY --from=APPCDS /helloworld-springboot-tomcat-shaded-0.0.1-SNAPSHOT.jar /helloworld-springboot-tomcat-shaded-0.0.1-SNAPSHOT.jar
COPY --from=APPCDS /appcds.jsa /appcds.jsa

#ENTRYPOINT java -Xshare:on -XX:SharedArchiveFile=appcds.jsa -jar helloworld-springboot-tomcat-shaded-0.0.1-SNAPSHOT.jar
ENTRYPOINT java -jar helloworld-springboot-tomcat-shaded-0.0.1-SNAPSHOT.jar

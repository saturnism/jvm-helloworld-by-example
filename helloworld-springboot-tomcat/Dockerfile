FROM adoptopenjdk:11-jre-hotspot

COPY target/helloworld-springboot-tomcat-0.0.1-SNAPSHOT.jar /helloworld-springboot-tomcat-0.0.1-SNAPSHOT.jar

#ENTRYPOINT java -Xshare:on -XX:SharedArchiveFile=appcds.jsa -jar helloworld-springboot-tomcat-0.0.1-SNAPSHOT.jar
ENTRYPOINT java -jar helloworld-springboot-tomcat-0.0.1-SNAPSHOT.jar

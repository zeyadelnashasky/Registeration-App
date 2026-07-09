FROM tomcat:latest
RUN rm -rf /usr/local/tomcat/webapps/* && cp -R /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps
EXPOSE 8080
COPY /webapp/target/*.war /usr/local/tomcat/webapps/ROOT.war
CMD ["catalina.sh", "run"]


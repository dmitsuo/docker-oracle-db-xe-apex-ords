FROM tomcat:9.0.73-jdk11-temurin-jammy

ARG ARG_ORDS_CONTAINER_USER_UID=1000
ARG ARG_ORDS_CONTAINER_CONFIG_DIR=/opt/ords-config
ARG ARG_ORDS_FOLDER_NAME=./ords-22.4.4.041.1526
ARG ARG_DEFAULT_TIMEZONE="America/Fortaleza"

RUN set -eux ; \
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 > /tmp/myfile    ; \
    ${JAVA_HOME}/bin/keytool -genkeypair -alias tomcat -keyalg RSA -keysize 2048      \
    -storetype PKCS12 -keystore ${CATALINA_HOME}/conf/tomcat-keystore.p12 -validity 3650   \
    -dname "cn=ORDS,ou=IT,o=ACME,l=SPRINGFIELD,s=MO,c=USA"                  \
    -keypass $(cat /tmp/myfile) -storepass $(cat /tmp/myfile)                       ; \
    sed -i "113s|.*|<Connector port=\"8443\" protocol=\"org.apache.coyote.http11.Http11NioProtocol\" maxThreads=\"200\" SSLEnabled=\"true\" scheme=\"https\" secure=\"true\" keystoreFile=\"${CATALINA_HOME}/conf/tomcat-keystore.p12\" keystorePass=\"$(cat /tmp/myfile)\" clientAuth=\"false\" sslProtocol=\"TLS\" compression=\"on\" compressionMinSize=\"128\" compressibleMimeType=\"application/json,text/html,text/xml,application/xml,application/xhtml+xml,text/javascript,text/css,text/plain,text/csv,text/rtf,application/x-javascript,application/javascript,image/svg+xml\" />|" ${CATALINA_HOME}/conf/server.xml ; \
    rm -f /tmp/myfile ; \
    echo "\nexport JAVA_OPTS=\"\$JAVA_OPTS -Dconfig.url=$ARG_ORDS_CONTAINER_CONFIG_DIR -Duser.language=pt -Duser.country=BR -Duser.timezone=$ARG_DEFAULT_TIMEZONE\"" >> ${CATALINA_HOME}/bin/setenv.sh ; \
    echo "\njava.util.logging.SimpleFormatter.format=%1\$tF %1\$tT [%4\$s][%2\$s] %5\$s %6\$s %n" >> ${CATALINA_HOME}/conf/logging.properties ; \
    sed -i "71s|.*|redirectPort=\"8443\" compression=\"on\" compressionMinSize=\"128\" compressibleMimeType=\"application/json,text/html,text/xml,application/xml,application/xhtml+xml,text/javascript,text/css,text/plain,text/csv,text/rtf,application/x-javascript,application/javascript,image/svg+xml\"/>|" ${CATALINA_HOME}/conf/server.xml ; \
    sed -i "153s|.*|<Valve className=\"org.apache.catalina.valves.ErrorReportValve\" showServerInfo=\"false\" showReport=\"false\"/>|" ${CATALINA_HOME}/conf/server.xml ; \
    groupadd -g $ARG_ORDS_CONTAINER_USER_UID -r chaos ; \
    useradd -u $ARG_ORDS_CONTAINER_USER_UID -r -s /bin/false -g chaos chaos ; \
    chown -R chaos:chaos ${CATALINA_HOME} ; \
    chmod -R 750 ${CATALINA_HOME}

COPY --chown=$ARG_ORDS_CONTAINER_USER_UID:$ARG_ORDS_CONTAINER_USER_UID $ARG_ORDS_FOLDER_NAME/ords.war $CATALINA_HOME/webapps/

EXPOSE 8080 8443
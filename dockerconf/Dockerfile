#FROM openjdk:8-alpine3.9
FROM maven:3.8.1-ibmjava-8-alpine as builder


COPY . /app
WORKDIR /app
RUN mvn clean package -DskipJSTests -DskipTests -Drat.skip=true

FROM maven:3.8.1-ibmjava-8-alpine

ENV APP_VERSION 1.8.4
WORKDIR /app

RUN apk add mariadb-dev mariadb-client
# mariadb/mysql odbc/jdbc lib package is still WIP in alpine, installing platform independent binary
ARG JDBC_DRV_VER=8.0.18
ARG TRINO_JDBC_VERSION=355
RUN mkdir -p /usr/share/java \
    && curl -SL "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${JDBC_DRV_VER}.tar.gz" \
    | tar -xzC /usr/share/java/ \
    && curl -O "https://repo1.maven.org/maven2/io/trino/trino-jdbc/${TRINO_JDBC_VERSION}/trino-jdbc-${TRINO_JDBC_VERSION}.jar" \
    && mv "./trino-jdbc-${TRINO_JDBC_VERSION}.jar" "/usr/share/java/trino-jdbc-${TRINO_JDBC_VERSION}.jar" \
    && echo "export CLASSPATH=/usr/share/java/mysql-connector-java-${JDBC_DRV_VER}/mysql-connector-java-${JDBC_DRV_VER}.jar:$CLASSPATH" >> /etc/profile \
    && echo "export CLASSPATH=/usr/share/java/trino-jdbc-${TRINO_JDBC_VERSION}.jar:$CLASSPATH" >> /etc/profile

COPY --from=builder /app/gateway-ha/target/gateway-ha-"${APP_VERSION}"-jar-with-dependencies.jar .
COPY --from=builder /app/gateway-ha/gateway-ha-config.yml .
COPY --from=builder /app/gateway-ha/src/main/resources/gateway-ha-persistence.sql .
COPY --from=builder /app/dockerconf/entrypoint.sh ./dockerconf/entrypoint.sh

ENV PERSISTANCE_DB_BOOTSTRAP "/app/gateway-ha-persistence.sql" 
ENV GATEWAY_HA_CONFIG_FILE "/app/gateway-ha-config.yml" 
ENV APP_BINARY "/app/gateway-ha-"${APP_VERSION}"-jar-with-dependencies.jar"

ENV ROUTER_PORT 8080
ENV APP_PORT 8090
ENV ADMIN_PORT 8091
EXPOSE ${ROUTER_PORT}
EXPOSE ${APP_PORT}
EXPOSE ${ADMIN_PORT}

ENTRYPOINT ["/app/dockerconf/entrypoint.sh"]
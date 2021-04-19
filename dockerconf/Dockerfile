FROM maven:3.8-openjdk-15-slim as builder

COPY . /app
WORKDIR /app
RUN mvn clean package -DskipTests -Dmaven.artifact.threads=20

FROM adoptopenjdk/openjdk15:alpine-jre

WORKDIR /app

RUN apk add --no-cache mariadb-dev mariadb-client curl bash
# mariadb/mysql odbc/jdbc lib package is still WIP in alpine, installing platform independent binary
ARG JDBC_DRV_VER=8.0.18
RUN mkdir -p /usr/share/java \
    && curl -SL "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${JDBC_DRV_VER}.tar.gz" \
    | tar -xzC /usr/share/java/ \
    && echo "export CLASSPATH=/usr/share/java/mysql-connector-java-${JDBC_DRV_VER}/mysql-connector-java-${JDBC_DRV_VER}.jar:$CLASSPATH" >> /etc/profile

ENV APP_VERSION 1.8.6
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
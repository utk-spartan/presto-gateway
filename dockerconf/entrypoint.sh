#!/bin/bash
set -eu

initialize() {
    echo "Setting up config"
    APP_CONFIG=/tmp/config.yml
    cp "${GATEWAY_HA_CONFIG_FILE}" "${APP_CONFIG}"
    sed -i.u "s|DB_HOST|${DB_HOST}|g" "${APP_CONFIG}"
    sed -i.u "s|DB_PORT|${DB_PORT}|g" "${APP_CONFIG}"
    sed -i.u "s|DB_USER|${DB_USER}|g" "${APP_CONFIG}"
    sed -i.u "s|DB_PASS|${DB_PASS}|g" "${APP_CONFIG}"
    sed -i.u "s|DB_NAME|${DB_NAME}|g" "${APP_CONFIG}"
    sed -i.u "s|ROUTER_PORT|${ROUTER_PORT}|g" "${APP_CONFIG}"
    sed -i.u "s|APP_PORT|${APP_PORT}|g" "${APP_CONFIG}"
    sed -i.u "s|ADMIN_PORT|${ADMIN_PORT}|g" "${APP_CONFIG}"
}

check_mysql_connection()
{
    connected=0
    counter=0

    echo "Wait 60 seconds for connection to MySQL"
    while [[ ${counter} -lt 60 ]]; do
        {
            /usr/bin/mysql -u"${DB_USER}" -p"${DB_PASS}" -h "${DB_HOST}" --port="${DB_PORT}" -e "SELECT 1" \
            | echo "Connecting to MySQL" &&
            connected=1

        } || {
            let counter=$counter+3
            sleep 3
        }
        if [[ ${connected} -eq 1 ]]; then
            echo "Connected"
            break;
        fi
    done

    if [[ ${connected} -eq 0 ]]; then
        echo "MySQL process failed."
        exit;
    fi
}

setup_mysql_dev_schema()
{
    check_mysql_connection

    echo "Setting up DB: mysql"
    /usr/bin/mysql -u"${DB_USER}" -p"${DB_PASS}" -h "${DB_HOST}" --port="${DB_PORT}" -D ${DB_NAME} < "${PERSISTANCE_DB_BOOTSTRAP}"
}

run_app()
{
    echo "Running gateway Service"
    java -jar "${APP_BINARY}" server "${APP_CONFIG}"
}

initialize
check_mysql_connection
setup_mysql_dev_schema
run_app

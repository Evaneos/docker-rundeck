#!/bin/bash
set -e

if [ "$SERVER_URL" ]; then
    sed -i 's#^grails\.serverURL\=.*$#grails\.serverURL\='${SERVER_URL%/}'#g' /etc/rundeck/rundeck-config.properties
fi

if [ "${1:0:1}" = '-' ]; then
    set -- rundeck "$@"
fi

if [ "$1" = 'rundeck' ]; then
    echo "Starting rundeck"
    
    chown -R rundeck:rundeck /var/lib/rundeck
    
    ARGS=()
    for var in "$@"; do
        if [ "$var" == '--remove-auth-constraint' ]; then
            echo INFO: Removing auth constraint from /var/lib/rundeck/exp/webapp/WEB-INF/web.xml
            sed -ie "/<auth-constraint>/,/<\/auth-constraint>/d" /var/lib/rundeck/exp/webapp/WEB-INF/web.xml
            echo INFO: Succesfully removed auth constraint
        else
            ARGS+=("$var")
        fi
    done

    mkdir -p /tmp/rundeck
    echo gosu rundeck rundeck "${ARGS[@]}"
    exec gosu rundeck rundeck "${ARGS[@]}"
fi

exec "$@"
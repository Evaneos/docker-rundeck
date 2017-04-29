#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
	set -- rundeck "$@"
fi

if [ "$1" = 'rundeck' ]; then
	chown -R rundeck $RDECK_BASE
    
    ARGS=()
    for var in "$@"; do
        if [ "$var" == '--remove-auth-constraint' ]; then
        	echo INFO: Removing auth constraint from ${RDECK_BASE}/server/exp/webapp/WEB-INF/web.xml
        	sed -ie "/<auth-constraint>/,/<\/auth-constraint>/d" ${RDECK_BASE}/server/exp/webapp/WEB-INF/web.xml
        	echo INFO: Succesfully removed auth constraint
        else
        	ARGS+=("$var")
        fi
    done

	exec su-exec rundeck java -jar ${RDECK_BASE}/app.jar "${ARGS[@]}" --skipinstall
fi

exec "$@"
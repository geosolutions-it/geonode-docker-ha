#!/bin/bash
set -e

source /root/.bashrc

INVOKE_LOG_STDOUT=${INVOKE_LOG_STDOUT:-TRUE}
invoke () {
    if [ $INVOKE_LOG_STDOUT = 'true' ] || [ $INVOKE_LOG_STDOUT = 'True' ]
    then
        /usr/local/bin/invoke $@
    else
        /usr/local/bin/invoke $@ > /usr/src/geonode/invoke.log 2>&1
    fi
    echo "$@ tasks done"
}

# control the values of LB settings if present
if [ -n "$GEONODE_LB_HOST_IP" ];
then
    echo "GEONODE_LB_HOST_IP is defined and not empty with the value '$GEONODE_LB_HOST_IP' "
    echo export GEONODE_LB_HOST_IP=${GEONODE_LB_HOST_IP} >> /root/.override_env
else
    echo "GEONODE_LB_HOST_IP is either not defined or empty setting the value to 'django' "
    echo export GEONODE_LB_HOST_IP=django >> /root/.override_env
    export GEONODE_LB_HOST_IP=django
fi

if [ -n "$GEONODE_LB_PORT" ];
then
    echo "GEONODE_LB_HOST_IP is defined and not empty with the value '$GEONODE_LB_PORT' "
    echo export GEONODE_LB_PORT=${GEONODE_LB_PORT} >> /root/.override_env
else
    echo "GEONODE_LB_PORT is either not defined or empty setting the value to '8000' "
    echo export GEONODE_LB_PORT=8000 >> /root/.override_env
    export GEONODE_LB_PORT=8000
fi

if [ -n "$GEOSERVER_LB_HOST_IP" ];
then
    echo "GEOSERVER_LB_HOST_IP is defined and not empty with the value '$GEOSERVER_LB_HOST_IP' "
    echo export GEOSERVER_LB_HOST_IP=${GEOSERVER_LB_HOST_IP} >> /root/.override_env
else
    echo "GEOSERVER_LB_HOST_IP is either not defined or empty setting the value to 'geoserver' "
    echo export GEOSERVER_LB_HOST_IP=geoserver >> /root/.override_env
    export GEOSERVER_LB_HOST_IP=geoserver
fi

if [ -n "$GEOSERVER_LB_PORT" ];
then
    echo "GEOSERVER_LB_PORT is defined and not empty with the value '$GEOSERVER_LB_PORT' "
    echo export GEOSERVER_LB_PORT=${GEOSERVER_LB_PORT} >> /root/.override_env
else
    echo "GEOSERVER_LB_PORT is either not defined or empty setting the value to '8000' "
    echo export GEOSERVER_LB_PORT=8080 >> /root/.override_env
    export GEOSERVER_LB_PORT=8080
fi

# If DATABASE_HOST is not set in the environment, use the default value
if [ -n "$DATABASE_HOST" ];
then
    echo "DATABASE_HOST is defined and not empty with the value '$DATABASE_HOST' "
    echo export DATABASE_HOST=${DATABASE_HOST} >> /root/.override_env
else
    echo "DATABASE_HOST is either not defined or empty setting the value to 'db' "
    echo export DATABASE_HOST=db >> /root/.override_env
    export DATABASE_HOST=db
fi

# If DATABASE_PORT is not set in the environment, use the default value
if [ -n "$DATABASE_PORT" ];
then
    echo "DATABASE_PORT is defined and not empty with the value '$DATABASE_PORT' "
    echo export DATABASE_HOST=${DATABASE_PORT} >> /root/.override_env
else
    echo "DATABASE_PORT is either not defined or empty setting the value to '5432' "
    echo export DATABASE_PORT=5432 >> /root/.override_env
    export DATABASE_PORT=5432
fi

# If GEONODE_GEODATABASE_USER is not set in the environment, use the default value
if [ -n "$GEONODE_GEODATABASE" ];
then
    echo "GEONODE_GEODATABASE is defined and not empty with the value '$GEONODE_GEODATABASE' "
    echo export GEONODE_GEODATABASE=${GEONODE_GEODATABASE} >> /root/.override_env
else
    echo "GEONODE_GEODATABASE is either not defined or empty setting the value '${COMPOSE_PROJECT_NAME}_data' "
    echo export GEONODE_GEODATABASE=${COMPOSE_PROJECT_NAME}_data >> /root/.override_env
    export GEONODE_GEODATABASE=${COMPOSE_PROJECT_NAME}_data
fi

# If GEONODE_GEODATABASE_USER is not set in the environment, use the default value
if [ -n "$GEONODE_GEODATABASE_USER" ];
then
    echo "GEONODE_GEODATABASE_USER is defined and not empty with the value '$GEONODE_GEODATABASE_USER' "
    echo export GEONODE_GEODATABASE_USER=${GEONODE_GEODATABASE_USER} >> /root/.override_env
else
    echo "GEONODE_GEODATABASE_USER is either not defined or empty setting the value '$GEONODE_GEODATABASE' "
    echo export GEONODE_GEODATABASE_USER=${GEONODE_GEODATABASE} >> /root/.override_env
    export GEONODE_GEODATABASE_USER=${GEONODE_GEODATABASE}
fi

# If GEONODE_GEODATABASE_USER is not set in the environment, use the default value
if [ -n "$GEONODE_GEODATABASE_PASSWORD" ];
then
    echo "GEONODE_GEODATABASE_PASSWORD is defined and not empty with the value '$GEONODE_GEODATABASE_PASSWORD' "
    echo export GEONODE_GEODATABASE_PASSWORD=${GEONODE_GEODATABASE_PASSWORD} >> /root/.override_env
else
    echo "GEONODE_GEODATABASE_PASSWORD is either not defined or empty setting the value '${GEONODE_GEODATABASE}' "
    echo export GEONODE_GEODATABASE_PASSWORD=${GEONODE_GEODATABASE} >> /root/.override_env
    export GEONODE_GEODATABASE_PASSWORD=${GEONODE_GEODATABASE}
fi

# If GEONODE_GEODATABASE_SCHEMA is not set in the environment, use the default value
if [ -n "$GEONODE_GEODATABASE_SCHEMA" ];
then
    echo "GEONODE_GEODATABASE_SCHEMA is defined and not empty with the value '$GEONODE_GEODATABASE_SCHEMA' "
    echo export GEONODE_GEODATABASE_SCHEMA=${GEONODE_GEODATABASE_SCHEMA} >> /root/.override_env
else
    echo "GEONODE_GEODATABASE_SCHEMA is either not defined or empty setting the value to 'public'"
    echo export GEONODE_GEODATABASE_SCHEMA=public >> /root/.override_env
    export GEONODE_GEODATABASE_SCHEMA=public
fi

if [ ! -z "${GEOSERVER_JAVA_OPTS}" ]
then
    echo "GEOSERVER_JAVA_OPTS is filled so I replace the value of '$JAVA_OPTS' with '$GEOSERVER_JAVA_OPTS'"
    export JAVA_OPTS=${GEOSERVER_JAVA_OPTS}
fi

JAVA_OPTS="$JAVA_OPTS -DGEOSERVER_LOG_LOCATION=$GEOSERVER_LOGS_DIR/$(hostname).log"
export JAVA_OPTS

# control the value of NGINX_BASE_URL variable
if [ -z `echo ${NGINX_BASE_URL} | sed 's/http:\/\/\([^:]*\).*/\1/'` ]
then
    echo "NGINX_BASE_URL is empty so I'll use the default Geoserver base url"
    echo "Setting GEOSERVER_LOCATION='${SITEURL}'"
    echo export GEOSERVER_LOCATION=${SITEURL} >> /root/.override_env
else
    echo "NGINX_BASE_URL is filled so GEOSERVER_LOCATION='${NGINX_BASE_URL}'"
    echo "Setting GEOSERVER_LOCATION='${NGINX_BASE_URL}'"
    echo export GEOSERVER_LOCATION=${NGINX_BASE_URL} >> /root/.override_env
fi

if [ -n "$SUBSTITUTION_URL" ];
then
    echo "SUBSTITUTION_URL is defined and not empty with the value '$SUBSTITUTION_URL'"
    echo "Setting GEONODE_LOCATION='${SUBSTITUTION_URL}' "
    echo export GEONODE_LOCATION=${SUBSTITUTION_URL} >> /root/.override_env
else
    echo "SUBSTITUTION_URL is either not defined or empty so I'll use the default GeoNode location "
    echo "Setting GEONODE_LOCATION='http://${GEONODE_LB_HOST_IP}:${GEONODE_LB_PORT}' "
    echo export GEONODE_LOCATION=http://${GEONODE_LB_HOST_IP}:${GEONODE_LB_PORT} >> /root/.override_env
fi

# if we do not want a shared data_dir, use a host-specific path
if [ "$GEOSERVER_DATA_DIR_SHARED" -eq 0 ]; then
    GEOSERVER_DATA_DIR="$GEOSERVER_DATA_DIR/$(hostname)"
    export GEOSERVER_DATA_DIR
fi

if [ ${FORCE_REINIT} = "true" ]  || [ ${FORCE_REINIT} = "True" ] || [ ! -e "${GEOSERVER_DATA_DIR}/geoserver_init.lock" ]; then
    # Run async configuration, it needs Geoserver to be up and running
    nohup sh -c "invoke configure-geoserver" &
fi

# separate the cluster config dir
CLUSTER_CONFIG_DIR="$GEOSERVER_CLUSTER_CONFIG_DIR/$(hostname)"
export CLUSTER_CONFIG_DIR
mkdir -p "$CLUSTER_CONFIG_DIR"
JAVA_OPTS="$JAVA_OPTS -DCLUSTER_CONFIG_DIR=$CLUSTER_CONFIG_DIR"
export JAVA_OPTS

# Set a new cluster instanceName if not already set
#sed -i "s/^instanceName=$/instanceName=$(cat /proc/sys/kernel/random/uuid)/" "${CLUSTER_CONFIG_DIR}"/cluster.properties

# FIXME: this workaround (for a deploy in a Swarm) keeps GS from starting (and
# crashing) before JDBC can to connect to Postgres
attempts=0
while ! /usr/bin/pg_isready -h "$DATABASE_HOST"; do
  attempts=$((attempts + 1))
  printf "Checking database availability: attempt %s\n" "$attempts"
  sleep 1
done

# FIXME: this workaround (for a deploy in a Swarm) keeps GS from starting (and
# crashing) before ActiveMQ is available
if [ "$ACTIVEMQ_HOST_CHECK" -eq 1 ]; then
  attempts=0
  curl_exit_code=-1
  while [ "$curl_exit_code" -ne 0 ] && [ "$curl_exit_code" -ne 1 ]; do
    attempts=$((attempts + 1))
    printf "Checking ActiveMQ availability: attempt %s\n" "$attempts"
    set +e
    curl -sS --max-time 5 "$ACTIVEMQ_HOST":61616
    curl_exit_code=$?
    set -e
    sleep 1
  done
fi

# start tomcat
exec env JAVA_OPTS="${JAVA_OPTS}" catalina.sh run

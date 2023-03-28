#!/bin/bash
set -eu

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

. "$SCRIPT_PATH/00-setenv.sh"

PATH=$JAVA_HOME/bin:$ORDS_INSTALL_DIR/bin:$PATH

myecho "Installing Oracle REST Data Services (ORDS)..."

ords --config $ORDS_CONFIG install --log-folder $ORDS_LOGS --admin-user "$DB_ADMIN_USER" \
     --proxy-user --db-hostname $ORDS_DB_CONTAINER_INTERNAL_IP --db-port $DB_LISTENER_TCP_PORT --db-servicename $DB_SERVICENAME \
     --feature-sdw $ORDS_FEATURE_SDW --proxy-user-tablespace $ORDS_PROXY_USER_TABLESPACE  \
     --proxy-user-temp-tablespace $ORDS_PROXY_USER_TEMP_TABLESPACE --schema-tablespace $ORDS_SCHEMA_TABLESPACE \
     --schema-temp-tablespace $ORDS_SCHEMA_TEMP_TABLESPACE --password-stdin << EOF
$DB_ADMIN_PWD
$DB_ADMIN_PWD
EOF

#echo Ajustando os parâmetros do pool de conexões
sed -i "14s|.*|<entry key=\"jdbc.InitialLimit\">5</entry>|" ${ORDS_CONFIG}/databases/default/pool.xml
echo "<entry key=\"jdbc.MaxLimit\">20</entry>" >> ${ORDS_CONFIG}/databases/default/pool.xml
echo "</properties>" >> ${ORDS_CONFIG}/databases/default/pool.xml

myecho "ORDS installation completed!"
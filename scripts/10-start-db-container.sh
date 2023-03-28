#!/bin/bash

#set -eux
set -eu

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

. "$SCRIPT_PATH/00-setenv.sh"

myecho "Creating/initializing Oracle XE 18c container database - Container name: \"$DB_CONTAINER_NAME\"..."
DB_CONTAINER_START_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [[ $(check_container_status $DB_CONTAINER_NAME) == "$CONTAINER_RUNNING" ]]; then
  myecho "Container database \"$DB_CONTAINER_NAME\" is already running."
  DB_CONTAINER_START_TIME=$(sudo docker inspect --format='{{.Created}}' $DB_CONTAINER_NAME)
elif [[ $(check_container_status $DB_CONTAINER_NAME) == "$CONTAINER_NOT_RUNNING" ]]; then
  myecho "Container database \"$DB_CONTAINER_NAME\" is stopped. Initializing..."
  sudo docker start $DB_CONTAINER_NAME
else
  myecho "Container database \"$DB_CONTAINER_NAME\" is not found. Creating and running the container..."
  sudo docker run --name $DB_CONTAINER_NAME -d                                               \
                  -p    $DB_LISTENER_TCP_PORT:1521                                           \
                  -e    ORACLE_PASSWORD=$DB_ADMIN_PWD                                        \
                  -e    APEX_HOME=$APEX_INTERNAL_CONTAINER_DIR                               \
                  -e    APEX_ADMIN_EMAIL=$APEX_ADMIN_EMAIL                                   \
                  -e    APEX_ADMIN_PWD=$APEX_ADMIN_PWD                                       \
                  -e    APEX_DB_USER=$APEX_DB_USER                                           \
                  -e    DB_SERVICENAME=$DB_SERVICENAME                                       \
                  -e    TZ=$DEFAULT_TIMEZONE                                                   \
                  -v    $DB_CONTAINER_VOLUME:/opt/oracle/oradata                             \
                  -v    "$SCRIPT_PATH":/opt/temp                                             \
                  -v    "$APEX_INSTALL_DIR/apex":$APEX_INTERNAL_CONTAINER_DIR \
  gvenzl/oracle-xe:18
fi

## Aguarda até o banco de dados inicializar por completo
# Número máximo de tentativas
MAX_TRIES=18
COUNT=0
DB_READY=0
DB_READY_STRING="DATABASE IS READY TO USE"
SECONDS_TO_WAIT=10

# Execute um loop enquanto a flag for 0 e o contador for menor que o máximo de tentativas
while [ $DB_READY -eq 0 ] && [ $COUNT -lt $MAX_TRIES ]
do
  # Incremente o contador em 1
  COUNT=$((COUNT+1))
  #myecho "Verificando se o banco de dados do container \"$DB_CONTAINER_NAME\" está pronto para ser utilizado. Tentativa $COUNT..."
  # Execute o comando e armazene sua saída em uma variável
  OUTPUT=$(sudo docker logs --since $DB_CONTAINER_START_TIME $DB_CONTAINER_NAME)
  # Teste se a saída contém o padrão de string usando =~
  if [[ $OUTPUT =~ $DB_READY_STRING ]]
  then
    # Se sim, defina a flag como 1 e imprima uma mensagem de sucesso
    DB_READY=1
    myecho "Container database \"$DB_CONTAINER_NAME\" is ready to use!"
    # Termine o script com código de sucesso (0)
    exit 0     
  else 
    # Se não, imprima uma mensagem de espera e aguarde mais X segundos antes da próxima tentativa     
    myecho "Attempt $COUNT of $MAX_TRIES: Container database \"$DB_CONTAINER_NAME\" is not ready. Waiting $SECONDS_TO_WAIT seconds..."
    sleep $SECONDS_TO_WAIT 
  fi 
done 

# Se sair do loop sem encontrar o padrão, imprima uma mensagem de erro 
myecho "After $MAX_TRIES attempts, was not possible to check if database container \"$DB_CONTAINER_NAME\" is ready to use."
# Termine o script com código de erro (1)
exit 1
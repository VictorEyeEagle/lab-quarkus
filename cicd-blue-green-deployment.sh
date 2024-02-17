#!/bin/bash -xe

APP_NAME=$1
GREEN_CONTAINER_TAG=$2

if [ $# -lt 2 ]; then
  echo "Erro: Argumentos insuficientes fornecidos."
  echo "Uso: $0 <nome_da_aplicacao> <tag_do_container_verde>"
  exit 1
fi

BLUE_CONTAINERS=$(docker ps -qf "name=${APP_NAME}")
BLUE_CONTAINER_COUNT=$(echo "$BLUE_CONTAINERS" | wc -w | xargs)

GREEN_CONTAINER_COUNT=$((BLUE_CONTAINER_COUNT * 2))
if [[ $BLUE_CONTAINER_COUNT == 0 ]]; then
    GREEN_CONTAINER_COUNT=1
fi

TAG=$GREEN_CONTAINER_TAG docker compose up -d "$APP_NAME" --scale "$APP_NAME=$GREEN_CONTAINER_COUNT" --no-recreate --no-build

until [ "$(docker ps -q -f "name=${APP_NAME}" -f "health=healthy" | wc -l | xargs)" == $GREEN_CONTAINER_COUNT ]; do
    sleep 0.1;
done;

if [[ $BLUE_CONTAINER_COUNT -gt 0 ]]; then
    docker kill --signal=SIGTERM "$BLUE_CONTAINERS"
fi

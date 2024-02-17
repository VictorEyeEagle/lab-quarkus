#!/bin/bash -xe

APP_NAME=$1
ROOT_DIRECTORY=$(pwd)

if [ -z "$APP_NAME" ]; then
  echo "Erro: Argumento insuficiente fornecido."
  echo "Uso: $0 <nome_da_aplicacao>"
  exit 1
fi

cd "$APP_NAME"

./mvnw clean

./mvnw versions:set -DremoveSnapshot

APP_VERSION=$(./mvnw -q -Dexec.executable=echo -Dexec.args='${project.version}' --non-recursive exec:exec)

./mvnw package

./mvnw versions:set -DnextSnapshot

git add pom.xml
git commit -m "cicd: bump version ${APP_NAME}:${APP_VERSION}"

cd "$ROOT_DIRECTORY"

TAG=$APP_VERSION docker compose build --no-cache "$APP_NAME"

docker images "dio/${APP_NAME}"

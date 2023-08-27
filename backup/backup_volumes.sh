#! /bin/bash
# 2023-08-25 12:45:16 rjd
# Export volumes for possible re-import, or transfer to remote host.

source ../.env
echo "Exporting project  ${COMPOSE_PROJECT_NAME} volumes to ./${COMPOSE_PROJECT_NAME}_volumes"

vackup export ${COMPOSE_PROJECT_NAME}_logs-vol ./${COMPOSE_PROJECT_NAME}_volumes/${COMPOSE_PROJECT_NAME}_logs-vol.tar
vackup export ${COMPOSE_PROJECT_NAME}_root-vol ./${COMPOSE_PROJECT_NAME}_volumes/${COMPOSE_PROJECT_NAME}_root-vol.tar
vackup export ${COMPOSE_PROJECT_NAME}_psql-vol ./${COMPOSE_PROJECT_NAME}_volumes/${COMPOSE_PROJECT_NAME}_psql-vol.tar


#! /bin/bash
# 2023-08-25 12:45:16 rjd
# Export volumes for possible re-import, or transfer to remote host.

source ../.env
echo "Restoring project volumes from ./${COMPOSE_PROJECT_NAME}_volumes"

vackup import ./${COMPOSE_PROJECT_NAME}_volumes/${COMPOSE_PROJECT_NAME}_logs-vol.tar ${COMPOSE_PROJECT_NAME}_logs-vol
vackup import ./${COMPOSE_PROJECT_NAME}_volumes/${COMPOSE_PROJECT_NAME}_root-vol.tar ${COMPOSE_PROJECT_NAME}_root-vol
vackup import ./${COMPOSE_PROJECT_NAME}_volumes/${COMPOSE_PROJECT_NAME}_psql-vol.tar ${COMPOSE_PROJECT_NAME}_psql-vol


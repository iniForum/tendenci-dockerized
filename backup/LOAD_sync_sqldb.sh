#! /bin/bash

# 2023-08-18 11:24:32 rjd updated script to generalize back on the basis of ../.env settings

#  rjd 11/17/2018, 1:42:53 PM
# Restore a containerized postgresql database, using an
# an SQL file that was created by pg_dumpall (not pg_pgdump).
#
# This restore will COMPLETELY OVERWRITE the existing database.
#
# In this case the container is named ssn-postgresql, and it is present on the localhost,
# however, a restore to a remote host is also possible (-h container hostname).
#

source ../.env
echo "Loading ./${REMOTE_SYNC_HOST}_syn data to postgis container ${COMPOSE_PROJECT_NAME}_postgis"

cat $(pwd)/${REMOTE_SYNC_HOST}_sync/${REMOTE_SYNC_SQL} | docker exec -i ${COMPOSE_PROJECT_NAME}_postgis /usr/bin/psql -h localhost -U postgres


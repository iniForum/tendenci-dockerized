#! /bin/bash
#
# 2023-08-18 11:24:32 rjd updated script to generalize back on the basis of ../.env settings

# To restore databases:
# cat your_dump.sql | docker exec -i your-db-container psql -U postgres
#
# make sure the executing user is in docker group

source ../.env
echo "Backing up data from postgis container ${COMPOSE_PROJECT_NAME}_postgis to ./localhost"


docker exec -t ${COMPOSE_PROJECT_NAME}_postgis pg_dump -U postgres -Cc ssn > $(pwd)/localhost/dump_${COMPOSE_PROJECT_NAME}_`date +%Y-%m-%d"-T"%T`.sql

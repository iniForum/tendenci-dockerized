#! /bin/bash
# author: rjd

# 2023-08-18 15:01:35 rjd updated script to generalize back on the basis of ../.env settings

source .env

DB_HOST=${POSTGRES_HOST}
DB_USER=${POSTGRES_USER}
DB_PASS=${POSTGRES_PASSWORD}
DB_NAME=${POSTGRES_DB}

# The following script assumes that the db will be restored with using a dump / sql that
# also specifies the postgis extensions.
#
docker exec -it $DB_HOST psql -U postgres -c "DROP DATABASE $DB_NAME;"
docker exec -it $DB_HOST psql -U postgres -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
docker exec -it $DB_HOST psql -U postgres -c "ALTER ROLE $DB_USER SET client_encoding TO 'UTF8';"
docker exec -it $DB_HOST psql -U postgres -c "ALTER ROLE $DB_USER SET default_transaction_isolation TO 'read committed';"
docker exec -it $DB_HOST psql -U postgres -c "CREATE DATABASE $DB_NAME WITH TEMPLATE = template0 ENCODING = 'UTF8';"
docker exec -it $DB_HOST psql -U postgres -c "ALTER DATABASE $DB_NAME OWNER TO $DB_USER;"
docker exec -it $DB_HOST psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

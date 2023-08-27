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
echo "Restoring SQL backup to postgis container ${COMPOSE_PROJECT_NAME}_postgis."

# cat ./localhost/dump_${COMPOSE_PROJECT_NAME}.sql | docker exec -i ${COMPOSE_PROJECT_NAME}_postgis /usr/bin/psql -h localhost -U postgres

#!/bin/bash
printf "\nPlease select folder:\n"
select d in */; do test -n "$d" && break; echo ">>> Invalid Selection"; done
# cd "$d" && pwd

# files=( "$d"*.sql )
set -- "$d"*.sql
printf "\nPlease select dump to load:\n"
while true; do
    i=0
    for pathname do
        i=$(( i + 1 ))
        printf '%d) %s\n' "$i" "$pathname" >&2
    done

    printf 'Select file to upload, or 0 to exit: ' >&2
    read -r reply

    number=$(printf '%s\n' "$reply" | tr -dc '[:digit:]')

    if [ "$number" = "0" ]; then
        echo 'Bye!' >&2
        exit
    elif [ "$number" -gt "$#" ]; then
        echo 'Invalid choice, try again' >&2
    else
        break
    fi
done

shift "$(( number - 1 ))"
file=$1

while true; do

echo ""

read -p "Do you want to proceed restoring $file into ${COMPOSE_PROJECT_NAME}_postgis? (y/n) " yn

case $yn in 
	[yY] ) echo ""
    echo "Restoring the DB now"
    #cat ./$file | docker exec -i ${COMPOSE_PROJECT_NAME}_postgis /usr/bin/psql -h localhost -U postgres
    echo "cat ./$file | docker exec -i ${COMPOSE_PROJECT_NAME}_postgis /usr/bin/psql -h localhost -U postgres"
		break;;
	[nN] ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac

done



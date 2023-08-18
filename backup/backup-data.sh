#! /bin/bash
#
# see: https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes

# 2023-08-18 11:24:32 rjd updated script to generalize back on the basis of ../.env settings

# This script backs-up the data state of ${COMPOSE_PROJECT_NAME}_tendenci on the localhost
# The key state directories are ${TENDENCI_PROJECT_ROOT}/{conf, media, themes}
# The directories are store as their respective tar files, in ./restore/localhost
# Unless thes files are data and moved by another process, they will be overwritten by the next backup.
#
# The RESTORE script in this directory will restore these tars back into ${COMPOSE_PROJECT_NAME}_tendenci.
#
#
# make sure the executing user is in docker group
# Of course, the target container tendenc-ssn must be running!

source ../.env
echo "Backing up data from tendenci container ${COMPOSE_PROJECT_NAME}_tendenci to ./localhost"

docker run --rm --volumes-from ${COMPOSE_PROJECT_NAME}_tendenci -v $(pwd)/localhost:/backup ubuntu tar cvf /backup/conf.tar  -C ${TENDENCI_PROJECT_ROOT} conf
docker run --rm --volumes-from ${COMPOSE_PROJECT_NAME}_tendenci -v $(pwd)/localhost:/backup ubuntu tar cvf /backup/media.tar -C ${TENDENCI_PROJECT_ROOT} media
docker run --rm --volumes-from ${COMPOSE_PROJECT_NAME}_tendenci -v $(pwd)/localhost:/backup ubuntu tar cvf /backup/themes.tar -C ${TENDENCI_PROJECT_ROOT} themes
docker run --rm --volumes-from ${COMPOSE_PROJECT_NAME}_tendenci -v $(pwd)/localhost:/backup ubuntu tar cvf /backup/static.tar -C ${TENDENCI_PROJECT_ROOT} static

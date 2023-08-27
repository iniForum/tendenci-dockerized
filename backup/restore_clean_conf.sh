#! /bin/bash

# 2023-08-18 11:24:32 rjd updated script to generalize back on the basis of ../.env settings
# rjd 11/16/2018, 10:58:10 PM

# see: https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes

# This script restores the data state of ${COMPOSE_PROJECT_NAME}_tendenci on the localhost
# The key state directories are ${TENDENCI_PROJECT_ROOT}/{conf, media, themes}
# The directories are restored from their respective tar files, in ./localhost
# Typically, these tars would be from the last backup (which stores to ./localhost).
#
# The strategy is to create a temporary ubuntu container, which mounts 1) the backed up tar file 2) the volume that tendenci-${COMPOSE_PROJECT_NAME} uses for this data (volumes-from).
# Then ubuntu untars the backup into the relevant volume, and dies (such is Life..).
# This process is repeated for each of the relevant volumes.
#


source ../.env
echo "Restoring a clean conf from ./tendenci_14.5.1 data to tendenci container ${COMPOSE_PROJECT_NAME}_tendenci"

docker run --rm --volumes-from ${COMPOSE_PROJECT_NAME}_tendenci -v $(pwd)/tendenci_14.5.1:/backup ubuntu bash -c "cd ${TENDENCI_PROJECT_ROOT} && tar xvf /backup/conf.tar"

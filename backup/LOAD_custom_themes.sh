#! /bin/bash

# 2023-08-18 14:20:11 rjd updated script to generalize back on the basis of ../.env settings
# rjd 11/16/2018, 10:58:10 PM

# This script loads custom themes into ${TENDENCI_PROJECT_ROOT}/themes 

echo "Loading ./custom_themes to tendenci container ${COMPOSE_PROJECT_NAME}_tendenci"

docker run --rm --volumes-from ${COMPOSE_PROJECT_NAME}_tendenci -v $(pwd)/custom_themes:/backup ubuntu bash -c "cd ${TENDENCI_PROJECT_ROOT} && tar xvf /backup/themes.tar"


#! /bin/bash
# https://tendenci.readthedocs.io/en/latest/upgrade/point-update.html
# set correct permissions utility script  2023-08-27 19:42:20 rjd

chgrp -Rh ${TENDENCI_USER} ${TENDENCI_PROJECT_ROOT}/
chmod -R -x+X,g-w,o-rwx ${TENDENCI_PROJECT_ROOT}/
chmod -R ug-x+rwX,o-rwx ${TENDENCI_PROJECT_ROOT}/media/ ${TENDENCI_PROJECT_ROOT}/whoosh_index/
chown -Rh ${TENDENCI_USER}:"$(id -u -n)" /var/log/${APP_NAME}/
chmod -R -x+X,g+rw,o-rwx /var/log/${APP_NAME}/
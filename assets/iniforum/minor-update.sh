#! /bin/bash
# https://tendenci.readthedocs.io/en/latest/upgrade/point-update.html
# Utility script  2023-08-27 19:42:20 rjd
# Apply database and static media updates, then clear the cache:

cd ${TENDENCI_PROJECT_ROOT}
python3 manage.py migrate
python3 manage.py deploy
python3 manage.py clear_cache

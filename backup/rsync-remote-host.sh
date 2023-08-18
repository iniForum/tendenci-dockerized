#! /bin/bash

# 2023-08-18 13:25:11 rjd updated script to generalize back on the basis of ../.env settings

source ../.env
echo "Syncing ${REMOTE_SYNC_PATH} to ./${REMOTE_SYNC_HOST}_sync"

rsync -vropg --links --rsync-path="sudo rsync" ${REMOTE_SYNC_HOST}:${REMOTE_SYNC_PATH}/${REMOTE_SYNC_SQL} ./${REMOTE_SYNC_HOST}_sync/
rsync -vropg --links --rsync-path="sudo rsync" ${REMOTE_SYNC_HOST}:${REMOTE_SYNC_PATH}/*.tar ./${REMOTE_SYNC_HOST}_sync/
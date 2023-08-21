2023-08-20 11:02:34  rjd

# New tendenci / postgis backup directory organization

The directory consists of various scripts, and subdirectories containing the tar files to be {restored | loaded} to the postgis and tendenci containers. 

The scripts are generalized, and take their specific environmental variables from .env in the root directory ( ../.env ).

## Note: when loading sql and tar data
- There must be no other connections to the postgis container when clearing/loading etc sql files. Run docker-compose -f compose-tendenci down, and disconnect pgadmin (if in use) from the relevant database.
- Tendenci should be running in isolation (not serving the databse) when loading tar files etc. Run docker-compose -f compose-db down, to shut down postgis.
- Restart both containers after these procedures. 

## Loading data and sql from a remote site
1. set the REMOTE_SYNC_ host, path, and sql variables in ../.env
2. ensure that the dump_${REMOTE_SYNC_SQL}.sql file is a copy of the relevant (typically most recent) .sql file in the remove host's localhost backup directory.
3. run rsync_remote-host.sh
4. The subdirectory ./${REMOTE_SYNC_HOST}_sync should now contain the sql and tar data of the remote host backup ( in its localhost directory).
5. Restart both containers
6. Follow the additional directions for tendenci migrations etc in ../README.md

## localhost 
repository of local host backups of sql, and most recent tars. 

## custom-themes subdirectory
Contains a tar of iniForum custom themes for nrn and ssn, plus the most recent tendenci themes.

## clear-rebuild script
This is the original clear/build script, that does just that. Intialises the databse to project database name, user, passwords. **All tendenci material will be lost**.


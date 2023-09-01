# rjd Procedures for setting up and running dockerized tendenci.
This code, and my instructions, are modified from the Tendeci repository: git@github.com:tendenci/tendenci-dockerized.git.  The code has been elaborated for use in iniForum AMS proejcts.

This repository git@github.com:iniforum/tendenci-dockerized.git is a fork of theirs. Their orginal README.md can be found in this directory.


## Procedure for building latest Tendenci container for running an iniForum site;

### Overview
Overall the process of building an iniforum system is fairly well automated. However, there remain important manual steps, as described below. During this process there are few crucial issues to keep in mind:
1. The postgis postgresql database and tendenci must share the same datasae name, user, and password! 
2. Tendenci's settings.py file is crucial. If things are not running properly, 90% of the time this will be due to incorrect database and secrets settings in settings.py
3. Typically, we will be upgrading an exisitng AMS site; and so we will have to deal carefully with the compatibility between the old system, and the updated systenm's database, configuration, media, and themes. We want to retain all old material and update these with new developments. carefully labeled backups are key to the security of the upgrade.   
4. **BEWARE** Tendenci checks its mysite/conf directory for an initialization flag. If the flag is absent, the database will be initialized. The original flag_name was 'first_run', which is changed now to 'site_initialized_flag'.


### First stage: build the most recent base Tendenci system:
1. Run ./build.sh
2. Once you have verified that Tendenci site is running as expected, backup this reference Tendenci to ./backup/tendence_<>version>, using instructions in ./backup/README.md.
3. For good measure, connect to the db using PgAdmin, and ensure that the psql contins the coorect database and user.


./build.sh is the orignal tendenci pulled from the tendenci/tendenci-dockerized repo, via our iniForum fork iniform/tendenci-dockerized.

When the tendenci container runs, it checks for /conf/site_initialized_flag. If this file is absent (as it should be in a fresh build), it initializes the postgis container.

Notice that the image postgis/postgis is already configued for postgis. Nevertheless, for reasons best known to Tendenci, the tendenci setup procedure installs the old form of postgis templates, and then works from there. The tendeci build will install these templates automatically on intialization via the assets/install/init.db script. This script will also create a project database; together with username and and password for that database. These variables are taken from the compose yaml file, which in turn grabs them from .env

One the db is set up, tendenci container will perform a fresh install of tendenci. Finally it will start its webserver and you will find tendenci running at https://< whatever you have assigned in .env > 

### Second Stage:sync the remote webste data and sql to ./backup/< remotesite >_sync
Use the detailed instructions in the ./backup/README.md
1. go to remote host and backup the the remote sql and data.
2. use the local ./backup/rsync-remote-host.sh to sync the more data to the ./local/< remote host >_sync directory.

### Third stage: add the old system db to postgis :
Now we will use our comppose-db and compose-tendenci scripts rather than Tendenci's suppied docker-compose script. This is because we need to run db and tendenci containers separately during the update. SO:
1. stop and remove the base containers by running docker-compose -f compose-db.yml down, and similary for compose-tendenci.yml. Confirm with eg Portainer that these containers have been removed, and that PgAdmin is stopped (we do not ).
2. restart the db container only (The db generates erros if there are any connections to it other than the loaded).
3. run ./clear_build_database. This will drop and rebuild our db, and prepare for loading of existing old databse. Note this is a stupid step. We should be able to load over the tendenci db - but this generates unexplained errors. TODO: solve this problem!!
4. run ./RESTORE_sql.sh.  This will load your selected db (typically the most recent) from the ./backup/< remote >_sync directory. postgis will write its progress to stdout / logs. This process should (and must) complete without errors.

### Forth stage: allow tendeci to update db  :
The fresh installation Tendenci will bring with it the most recent Tendenci settings.py. The secret keys and database settings will be correct, however the EMAIL, NEWSLETTER, and STRIPE vallues will not be correctly set. They will be installed when we now bring up the Tendenci container.  

1. restart tendenci: docker-compose -f compose-tendenci up.While loading Tendenci reports the values of all revelant environamental variables (that it is grabbing form .env). Check that these are all correct. 
2. Eventually tendenci reports that it is operational. DO NOT try to run the website yet (tendenci is not yet configured)! 
3. Use RESTORE_data.sh to restore ONLY media.tar and themes.tar from the remote_sync repository.
4. Enter the running tendeci container usuing either Portainer, or docker exec -it < tendenci container name > /bin/bash, and check (eg using more or nano) that mysite/conf/settings.py are correct (ie conform to .env). Check that media and themes have been correctly loaded.
5. If all is well, go to (still inside the tendenci container) the install directory (mother of mysite). Here, run the script minor-update.sh. This must complete without errors. (Tendenci 'check' may report one or two warnings). Now run set-permissions.sh (to ensure that these are correctly set.)
6. go to the website url, and check that the site is running at the address specified in .env (and as specified in the traefic labels in compose-tendenci.yml). The first interactions will take time, because the site has to sort itself out, cache isloading, etc. Be patient.
7. Now stop both containers, and then bring the up again, together this time, using compose-production.yml. 
8. If all is well, then immediately backup the system to ./backup/localhost using both backup_sql.sh and backup_data.sh.
9. tag the unpdated tendenci image with the version number docker tag rjdini/tendenci:test rjdini/tendenci:< version number >
10. In both compose-temdence.yml and compose-production.yml, change the container image field in the tendeci service to rjdini/tendenci:< version number >
11. push the tendenci image: docker push rjdini/tendenci:< version number >
12. down and up again the compose-production.yml system, and confirm that all is well. Check that the correct image is running (docker container list, or portainer).

### Final stage: deploy to remote site
The above stages have yielded an upgraded version of the remote site, running at a local URL. We retain this developemnt version on dev as backup, and send a copy of it to the remote machine where we make adjsutment sfor remote deployment.
1. use rysnc or FileZilla to transfer a copy of the current project directory to eg < project_new > directory on the remote host.
2. pull the updated tendenci image: docker pull rjdini/tendenci:< version number >
3. on the remote host edit .env settings such as COMPOSE_PROJECT_NAME and SITE_URL to conform to the remote context.
4. check the traefic host tendenci.rule=Host and tendenci-secure.rule=Host settings to ensure that they conform to the required project URL settings.
5. stop the old site, and bring up the new site using compose-production.yml.
6. If all is well, move the old project directory to < old project directory >_old (keep for a few days, just incase...); and move < project_new > to < project >.
7. Finally - remove all developmental files and directories, leaving only those require for running the projection website: .env, compose-production.yml, ./backup/backup*, ./backup/RESTORE*, and ./backup/localhost.

Thats it!! hopefully...



----------------------------------------------------------------------
# Superceded notes and reminders

## Procedure for installing a remote site to run on these postgis and tendenci containers
1. Ensure that you have a clean new installation of Tendenci running (as above).
   - If you wish to use the current Tendeci version, then no fresh build is required.
   - If you wish to use the latest Tendenci version, then run ./build-part1.sh, followed by build-part2.sh. This will build rjdini/tendenci:latest (which you should finally (when all is checked) push to rjdini/tendenci:<version number> ).
2. Backup this reference version (see ./backup/README.md) to a backup directory tendenci_<version number>.
3. Sync and Load the remote site (see ./backup/README.md)
4. Optional: Load custom themes (see ./backup/README.md). You will not want to do this load, if e.g. the remote site uses a custom theme, and has been mofied on the remote system.
5. Run migrations etc as described below
6. When the site is fully fuction, back up sql and data to localhost (see ./backup/README.md) 

### Issues
Most difficulties (eg failure of connection to postgis, postgis complaints) are due to incorrect values in config/settings.py.
The easiest option would be to use the remote's version of settings.py
On the other hand, if there has been a major revision of Tendneci, then we should use that, and correct the crucial settings to match the remote.
The following settings of the remote settings.py must be applied to the current settings.py
1. SECRET keys
2. Database hostname, dbname, user, password
3. Mailer (eg SparkPost) settings and passwords.
4. STRIPE settings and passwords
5. Logger settings(if not default)
6. Others?

## Procedure for configuring the tendenci container after loading emote site data.
This procedure is still flakey (TODO rjd 2023-08-20 15:11:44), and needs to be finalized:
1. python3 ./manage.py migrations
2. python3 ./manage.py set_setting site global siteurl "https:/test.dev.iniforum.ch"
3. python3 ./manage.py deploy  (this gives a few errors due to duplicate entries - I think the first loaded (remote site) ones are preserved.)
4. python3 ./manage.py update_dashboard_stats
5. python3 ./manage.py set_theme <theme name> (for example, ssn2021)
6. python3 ./manage.py clear_cache


## Procedure for backing up and restoring a fully functional site
The backup will store a snapshot of the current site, overwrting the previous copy (if any). Only backup the site if it si fully fuctional. 
1. The site will be backed up to (or restored from) ./backup/localhost
2. Follow the instructions in ./backup/README.md

   


# rjd Temporary Notes
2023-08-16 10:46:15  rjd

2023-08-18 10:19:46  rjd

I cannot find the cause of the site_settings-setiing problem  described below. However, I notice that this error message occurs also during the build of the master tendenci-dockerized. And everything seems to work downstream of this error (which stops transmitting as soon as the tendenci container runs the initial migration).
So I am going to ignore this problem for the moment.  

------------------------------------

Process to initialize fresh database and restore to it a backup of one of iniforum's AMS sites.
The example here is for ssn, with a project name of 'test', which will run at https://test.dev.iniforum.ch.   Modify the .env file according to need.

For development (build convenience)I have split the Dockerfile into part 1 and 2, whith two matched build scripts. The first Dockerfile generates the basic ubuntu docker. The second installs tendenci.

I overwrite the run file with an external volume, to facilitate edited the runfile. 

1.  bring up the postgis/postgis:15-3.3 container. It self initializes postgres to postgis.
2.  bring up tendenci rjdini/tendenci:test container. ** be sure that POSTGRES_DB and POSTGRES_USER match the database will be restored later! Tendenci container now initializes postgis for a standard tendenci site. (During this load postgis initially complains that it has no site settings... why is this?)
test_postgis  | 2023-08-16 08:39:28.177 UTC [82] ERROR:  relation "site_settings_setting" does not exist at character 634
test_postgis  | 2023-08-16 08:39:28.177 UTC [82] STATEMENT:  SELECT "site_settings_setting"."id", "site_settings_setting"."name", "site_settings_setting"."label", "site_settings_setting"."description", "site_settings_setting"."data_type", "site_settings_setting"."value", "site_settings_setting"."default_value", "site_settings_setting"."input_type", "site_settings_setting"."input_value", "site_settings_setting"."client_editable", "site_settings_setting"."store", "site_settings_setting"."update_dt", "site_settings_setting"."updated_by", "site_settings_setting"."scope", "site_settings_setting"."scope_category", "site_settings_setting"."parent_id", "site_settings_setting"."is_secure" FROM "site_settings_setting" WHERE ("site_settings_setting"."name" = 'maxfilesize' AND "site_settings_setting"."scope" = 'module' AND "site_settings_setting"."scope_category" = 'files') LIMIT 21

Nevertheless - the standard tendeci site (green) is immediately available.
Inspection of tendenci container conf/settings.py confirms that both SECRET keys are correct, and also that the database settings are correct. /var/log contains both a tendenci (empty) and a mysite (contains app.log  debug.log) folder.


1. Restart of both containers.
2. Run manage.py migrate, deploy, load_tendenci_defaults, set_setting site global siteurl "https://ssn.dev.iniforum.ch" (or whatever). At this point the standard Tendenci site will run. 
3. run RESTORE_ssn_sqldb.sh  (To avoid conflicts, it may be wise to stop tendenci during this load)
4. in tendenci container, move themes to themes_new
5. run RESTORE_test_data.sh, loading only media and themes (its the ssn2021 theme that we need). (To avoid conflicts, it may be wise to stop postgis this load) Dont load conf (it will overwrite the operating one. And dont load static (which overwrites the new tendenci version of static)
7. transfer themes_new/tendenci2020 to themes (tendenci2020 is latest version of standed Tendenci look  )
8.  Restart both containers if they have been stopped.
9.  manage.py update_dashboard_stats
10. manage.py set_theme ssn2021 (for example)

Check that https://ssn.dev.iniforum.ch is alive. The theme may be garbled betwwen tendenci2020 and ssn2021. A restart of both containers should solve this, now exbiting pure ssn2021 theme.
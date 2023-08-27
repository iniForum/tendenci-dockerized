# rjd Procedures for setting up and running dockerized tendenci.
This code, and my instructions, are modified from the Tendeci repository: git@github.com:tendenci/tendenci-dockerized.git. 

This repository git@github.com:iniforum/tendenci-dockerized.git is a fork of theirs.

Their orginal README.md can be found in this directory.

## Overview
Overall the build is well automated. However, there are two crucial issues to keep in mid:
1. The postgis postgresql database and tendenci must share the same datasae name, user, and password! 
2. Tendenci's settings.py file is crucial. If things are not running properly, 90% of the time this will be due to incorrect database and secrets settings in settings.py

## Procedure for building latest Tendenci Docker
The standard way to generate a latest, base Tendeci system is:
1. Run ./build.sh
2. Once you have verified that Tendenci site is running as expected, backup this version reference version using instructions in ./backup/README.md

### Setting up the postgis database
Initialization of the container postgis/postgis is intialized by the tendenci container.

When the tendenci container runs, it checks for /conf/site_initialized_flag. If this file is absent, it initializes the postgis container.

The image postgis/postgis is already configued for postgis. However, the tendenci setup procedure calls for installing the old form of postgis templates. The docker build here will perfom this automatically on intialization via the assets/install/init.db script. This script will also create a project database; together with username and and password for that database. These variables are taken from the compose yaml file, which in turn grabs them from .env

One the db is set up, tendenci container will perform a fresh install of tendenci. Finally it will start its webserver and you will find tendenci running at https://< whatever you have assigned in .env > 

### BEWARE (rjd 2023-08-10 08:23:51)
Code checks conf directory for an initialization flag. If the flag is absent, the database will be intialized. The original flag_name was 'first_run', which is changed now to 'site_initialized_flag'.

## Configuring settings.py
The fresh installation Tendenci will bring with it the mst recent settings.py. The secret keys and databse settings will be correct, but the EMAIL, NEWSLETTER, and STRIPE vallues will not be correctly set. 

I have made a script load_iniforum_secrets in assets/runtime/run.sh that will grab the necessary values from the compose script, which in turn grabs them from .env. But sofar this script only updates existing values,which are not commented out!
SO the simple manual fix  is to exec into tendenci container, go to conf, nano settings.py. Now remove the comment character '#' to the left of the EMAIL, NEWSLETTER, and STRIPE fields. The run load_iniforum_secrets, and the fields will be correctly updated from .env.  Clunky I know!...

Now immediately backup the system using ./backup/backup_data.sh and ./backup/backup_sql.sh. These will store a snapshot in .localhost, which you can use to restore the system using the RESTORE scripts. (see the ./backup/ README.md for details).



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
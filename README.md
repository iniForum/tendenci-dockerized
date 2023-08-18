
2023-08-16 10:46:15  rjd

Process to initialize fresh database and restore to it a backup of one of iniforum's AMS sites.
The example here is for ssn, with a project name of 'test', which will run at https://test.dev.iniforum.ch.   Modify the .env file according to need.

For development (build convenience)I have split the Dockerfile into part 1 and 2, whith two matched build scripts. The first Dockerfile generates the basic ubuntu docker. The second installs tendenci.

I overwrite the run file with an external volume, to facilitate edited the runfile. 

1.  bring up the poatgis/postgis:15-3.3 container. It self initializes postgres to postgis.
2.  bring up tendenci rjdini/tendenci:test container. ** be sure that POSTGRES_DB and POSTGRES_USER match the datbase will be restored later! Tendenci container now initializes postgis for a standard tendenci site. (During this load postgis initially complains that it has no site settings... why is this?)
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
10. manage.py set_theme ssn2021 (for exmple)

Check that https://ssn.dev.iniforum.ch is alive. The theme may be garbled betwwen tendenci2020 and ssn2021. A restart of both containers should solve this, now exbiting pure ssn2021 theme.

----------------------------------------------------------------------


*This repo was originally transferred from @jucajuca. Thanks @jucajuca!*.

# Docker Tendenci

Docker file and docker-compose file to launch a tendenci instance.


## Installation

Install docker and git in your system

```bash
git clone https://github.com/tendenci/tendenci12-dockerized.git
``````

## Usage

Rename the .env.sample file to .env 
Edit the .env file and adjust your settings

```bash
docker build --no-cache=true --rm -t tendenci .
docker-compose up -d
``````

Do not forget the dot at the end of docker build

## BEWARE (rjd 2023-08-10 08:23:51)
Code checks conf directory for an initialization flag. If the flag is absent, the database will be intialized. The original flag_name was 'first_run', which is changed now to 'site_initialized_flag'.


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.


Based on : https://github.com/frenchbeard/docker-tendenci

## License
[MIT](https://choosealicense.com/licenses/mit/)


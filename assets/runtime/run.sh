#! /bin/bash
# 2023-08-23 23:38:51 rjd added init_cron, because the ubuntu container does not self start cron.

PYTHON=$(which python3)

function setup_keys()
{
    echo "Creating secret keys"  && echo ""

    SECRET_KEY=${SECRET_KEY:-$(mcookie)}
    SITE_SETTINGS_KEY=${SITE_SETTINGS_KEY:-$(mcookie)}
    sed -i "s/^SECRET_KEY.*/SECRET_KEY='$SECRET_KEY'/" \
       "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "SECRET_KEY: $SECRET_KEY" && echo ""
    sed -i "s/^SITE_SETTINGS_KEY.*/SITE_SETTINGS_KEY='$SITE_SETTINGS_KEY'/" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "SITE_SETTINGS_KEY: $SITE_SETTINGS_KEY" && echo ""
}

function load_iniForum_secrets
{
    # load secrets from compose file, which in turn is loading from .env
    echo "Loading secrets"  && echo ""

    # email settings   
    sed -i "s/^EMAIL_BACKEND\s*=.*/EMAIL_BACKEND='$EMAIL_BACKEND'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "EMAIL_BACKEND: $EMAIL_BACKEND" && echo ""

    sed -i "s/^EMAIL_USE_TLS\s*=.*/EMAIL_USE_TLS='$EMAIL_USE_TLS'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "EMAIL_USE_TLS: $EMAIL_USE_TLS" && echo ""

    sed -i "s/^EMAIL_HOST\s*=.*/EMAIL_HOST='$EMAIL_HOST'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "EMAIL_HOST: $EMAIL_HOST" && echo ""
    
    sed -i "s/^EMAIL_PORT\s*=.*/EMAIL_PORT='$EMAIL_PORT'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "EMAIL_PORT: $EMAIL_PORT" && echo ""
    
    sed -i "s/^EMAIL_HOST_USER\s*=.*/EMAIL_HOST_USER='$EMAIL_HOST_USER'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "EMAIL_HOST_USER: $EMAIL_HOST_USER" && echo ""
    
    sed -i "s/^EMAIL_HOST_PASSWORD\s*=.*/EMAIL_HOST_PASSWORD='$EMAIL_HOST_PASSWORD'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "EMAIL_HOST_PASSWORD: $EMAIL_HOST_PASSWORD" && echo ""

    sed -i "s/^DEFAULT_FROM_EMAIL\s*=.*/DEFAULT_FROM_EMAIL='$DEFAULT_FROM_EMAIL'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "DEFAULT_FROM_EMAIL: $DEFAULT_FROM_EMAIL" && echo ""

    sed -i "s/^SERVER_EMAIL\s*=.*/SERVER_EMAIL='$SERVER_EMAIL'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "SERVER_EMAIL: $SERVER_EMAIL" && echo ""

    # email newsletter settings
    sed -i "s/^NEWSLETTER_EMAIL_HOST\s*=.*/NEWSLETTER_EMAIL_HOST='$NEWSLETTER_EMAIL_HOST'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "NEWSLETTER_EMAIL_HOST: $NEWSLETTER_EMAIL_HOST" && echo ""

    sed -i "s/^NEWSLETTER_EMAIL_PORT\s*=.*/NEWSLETTER_EMAIL_PORT='$NEWSLETTER_EMAIL_PORT'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "NEWSLETTER_EMAIL_PORT: $NEWSLETTER_EMAIL_PORT" && echo ""

    sed -i "s/^NEWSLETTER_EMAIL_HOST_USER\s*=.*/NEWSLETTER_EMAIL_HOST_USER='$NEWSLETTER_EMAIL_HOST_USER'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "NEWSLETTER_EMAIL_HOST_USER: $NEWSLETTER_EMAIL_HOST_USER" && echo ""

    sed -i "s/^NEWSLETTER_EMAIL_HOST_PASSWORD\s*=.*/NEWSLETTER_EMAIL_HOST_PASSWORD='$NEWSLETTER_EMAIL_HOST_PASSWORD'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "NEWSLETTER_EMAIL_HOST_PASSWORD: $NEWSLETTER_EMAIL_HOST_PASSWORD" && echo ""

    # STRIPE settings
    sed -i "s/^STRIPE_SECRET_KEY\s*=.*/STRIPE_SECRET_KEY='$STRIPE_SECRET_KEY'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "STRIPE_SECRET_KEY: $STRIPE_SECRET_KEY" && echo ""

    sed -i "s/^STRIPE_PUBLISHABLE_KEY\s*=.*/STRIPE_PUBLISHABLE_KEY='$STRIPE_PUBLISHABLE_KEY'/g" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"
    echo "STRIPE_PUBLISHABLE_KEY: $STRIPE_PUBLISHABLE_KEY" && echo ""

}






function create_settings
{
    echo "Creating settings"  && echo ""

     sed -i "s/^#DATABASES\['default'\]\['NAME'\].*/DATABASES\['default'\]\['NAME'\] = '${DB_NAME:-tendenci}'/" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"

     sed -i "s/^#DATABASES\['default'\]\['HOST'\].*/DATABASES\['default'\]\['HOST'\] = '${DB_HOST:-localhost}'/" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"

     sed -i "s/^#DATABASES\['default'\]\['USER'\].*/DATABASES\['default'\]\['USER'\] = '${DB_USER:-tendenci}'/" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"

     sed -i "s/^#DATABASES\['default'\]\['PASSWORD'\].*/DATABASES\['default'\]\['PASSWORD'\] = '${DB_PASS:-password}'/" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"

     sed -i "s/^#DATABASES\['default'\]\['PORT'\].*/DATABASES\['default'\]\['PORT'\] = '${DB_PORT:-5432}'/" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"

     sed -i "s/TIME_ZONE.*/TIME_ZONE='${TIME_ZONE:-GMT+0}'/" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"

     sed -i "s/ALLOWED_HOSTS =.*/ALLOWED_HOSTS = \[${ALLOWED_HOSTS:-'\*'}\]/" \
        "$TENDENCI_PROJECT_ROOT/conf/settings.py"

    echo "Finished creating settings" && echo ""
}



function create_superuser
{
    echo "Starting super user set-up" && echo ""
    
    cd "$TENDENCI_PROJECT_ROOT"
    echo "from django.contrib.auth import get_user_model; \
        User = get_user_model(); User.objects.create_superuser( \
        '${ADMIN_USER:-admin}', \
        '${ADMIN_MAIL:-admin@example.com}', \
        '${ADMIN_PASS:-password}')" \
        | "$PYTHON" manage.py shell
    
    echo "Finished super user set-up" && echo ""

}

function initial_setup
{

    cd "$TENDENCI_PROJECT_ROOT"
    "$PYTHON" manage.py initial_migrate 
    "$PYTHON" manage.py deploy
    "$PYTHON" manage.py load_tendenci_defaults
    "$PYTHON" manage.py update_dashboard_stats
    "$PYTHON" manage.py set_setting site global siteurl "$SITE_URL" 	

    create_superuser
    
    touch "$TENDENCI_PROJECT_ROOT/conf/site_initialized_flag"
    echo  "Initial set up completed" && echo ""

}




function init_cron
{    
   
    # touch /var/log/cron.log  # for debugging
    
    # 2023-08-24 08:52:45 rjd: this crontab entry is used for debugging, The routine cronatbs are set in install.sh 
    # Generating a crontab entry in as output from a bash script (such as this) for a substitution variable such as $(date) is tricky! 
    # We must escape the inner (transmitted to crontab) echo enclosing quotes as \" and also escape $ as \$
    # The -u option in sort is for keeping only unique lines. Note however, that sort may reorder the file job lines.
    (crontab -l; echo "*/5 * * * * /usr/bin/echo \"\$(date) This is a cron execution test.\" > /proc/1/fd/1 2>&1") | sort -u | crontab - 
    
    # (crontab -l ; echo "30 0 * * * $PYTHON $TENDENCI_PROJECT_ROOT/manage.py run_nightly_commands > /proc/1/fd/1 2>&1") | crontab -
    (crontab -l ; echo "*/10 * * * * /usr/bin echo "cron is running process_unindexed" > /proc/1/fd/1 2>&1 && $PYTHON $TENDENCI_PROJECT_ROOT/manage.py process_unindexed > /proc/1/fd/1 2>&1") | crontab -


    # cron must be started here. The unbuntu image does not auto start cron (or other forks).
     echo  "***** Starting cron ******* " && echo ""
    /etc/init.d/cron start
}

   
function run
{
    echo  "***** Starting Tendenci Server ******* " && echo ""
    cd "$TENDENCI_PROJECT_ROOT" \
    && "$PYTHON" manage.py runserver 0.0.0.0:8000 \
    
}   



if [ ! -f "$TENDENCI_PROJECT_ROOT/conf/site_initialized_flag" ]; then

# ******* Note that these functions write (by echo) secrets to docker logs for the container. Is thsi a security risk?
    setup_keys
    create_settings
    initial_setup         
    load_iniForum_secrets 
    run "$@"
else
    load_iniForum_secrets # testing here - in future this will run under first intialization
    init_cron  # only run cron on an intialized, and restarted, system    
    run "$@"
fi

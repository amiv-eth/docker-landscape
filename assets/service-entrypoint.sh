#!/bin/bash

# set -e

# ----------------------------------------------------------
# Set default values for missing inputs
# ----------------------------------------------------------

source /landscape.conf

# Database
DB_LANDSCAPE_USER=landscape
DB_LANDSCAPE_PASS=${DB_LANDSCAPE_PASS:-password}
DB_HOST=${DB_HOST:-}
DB_PORT=${DB_PORT:-5432}
DB_ADMIN_USER=${DB_ADMIN_USER:-postgres}
DB_ADMIN_PASS=${DB_ADMIN_PASS:-password}
DB_NAME=${DB_NAME:-postgres}

# RMQ
RMQ_HOST=${RMQ_HOST:-}
RMQ_PORT=${RMQ_PORT:-5672}
RMQ_USER=${RMQ_USER:-guest}
RMQ_PASS=${RMQ_PASS:-guest}
RMQ_VHOST=${RMQ_VHOST:-/}

if [[ -z $DB_HOST ]]; then
	echo "ERROR: "
	echo "   Please configure the database connection"
	exit 1
fi

if [[ -z $RMQ_HOST ]]; then
	echo "ERROR: "
	echo "   Please configure the RabbitMQ connection"
	exit 1
fi

#Set postgres variables for commandline usage
PGHOST=${DB_HOST}
PGPORT=${DB_PORT}
export PGUSER=${DB_ADMIN_USER}
export PGPASSWORD=${DB_ADMIN_PASS}
PGNAME=${DB_NAME}

#Support additiona environment variables if in container
PGUSER=${PGUSER:-${POSTGRES_ENV_PGUSER}}
PGPASSWORD=${PGPASSWORD:-${POSTGRES_ENV_PGPASSWORD}}

PGUSER=${PGUSER:-${POSTGRES_ENV_USERNAME}}
PGPASSWORD=${PGPASSWORD:-${POSTGRES_ENV_PASSWORD}}

# ----------------------------------------------------------
# Function: initialize configuration files
# ----------------------------------------------------------
function init {
  # Wait for the database server to become active
  prog=$(find /usr/lib/postgresql/ -name pg_isready)
  prog="${prog} -h ${DB_HOST} -p ${DB_PORT} -U ${DB_ADMIN_USER} -d ${DB_ADMIN_NAME} -t"
 
  timeout=60
  printf "Waiting for database server to become ready"
  while ! ${prog} >/dev/null 2>&1
    do
    timeout=$(expr $timeout - 1 )
    if [[ $timeout -eq 0 ]]; then
      printf "\nCould not connect to database server. Aborting...\n"
      exit 1
    fi
    printf "."
    sleep 1
  done

  # Update the config file to include all the relevant pieces
  sed -i 's,{{DB_LANDSCAPE_USER}},'"${DB_LANDSCAPE_USER}"',g' /etc/landscape/service.conf
  sed -i 's,{{DB_LANDSCAPE_PASS}},'"${DB_LANDSCAPE_PASS}"',g' /etc/landscape/service.conf
  sed -i 's,{{DB_ADMIN_USER}},'"${DB_ADMIN_USER}"',g' /etc/landscape/service.conf
  sed -i 's,{{DB_ADMIN_PASS}},'"${DB_ADMIN_PASS}"',g' /etc/landscape/service.conf
  sed -i 's,{{DB_HOST}},'"${DB_HOST}"',g' /etc/landscape/service.conf
  sed -i 's,{{DB_PORT}},'"${DB_PORT}"',g' /etc/landscape/service.conf

  sed -i 's,{{RMQ_HOST}},'"${RMQ_HOST}"',g' /etc/landscape/service.conf
  sed -i 's,{{RMQ_PORT}},'"${RMQ_PORT}"',g' /etc/landscape/service.conf
  sed -i 's,{{RMQ_USER}},'"${RMQ_USER}"',g' /etc/landscape/service.conf
  sed -i 's,{{RMQ_PASS}},'"${RMQ_PASS}"',g' /etc/landscape/service.conf
  sed -i 's,{{RMQ_VHOST}},'"${RMQ_VHOST}"',g' /etc/landscape/service.conf

  # Make sure permissions are correct
  chmod 644 /etc/landscape/service.conf

  # Enable specified service for running
  sed -i 's,RUN_'"${SERVICE}"'="no",RUN_'"${SERVICE}"'="yes",g' /etc/default/landscape-server
  printf "Service ${SERVICE} enabled.\n"

  # Copy default files if empty volumes are mounted
  if [ !"$(ls -A /var/lib/landscape)" ]; then
    cp -R /data/landscape /var/lib
  fi

  if [ !"$(ls -A /var/lib/landscape)" ]; then
    cp -R /data/landscape-server /var/lib
  fi
}

# ----------------------------------------------------------
# Function: starts rsyslog daemon
# ----------------------------------------------------------
startSyslog () {
  if ! pgrep rsyslogd 
  then
    printf "Starting rsyslogd\n"
    rsyslogd
  fi
}

# ----------------------------------------------------------
# Function: runs schema updates on the database
# ----------------------------------------------------------
function upgradeSchema {
  init
  startSyslog
  printf "Running schema check\n"

  # Landscape does an annoying thing, if the landscape schema does not exist
  # it creates it and the landscape role with a new password and then
  # updates the config file inside the container with the new password.
  # This means you have no idea what the password is when a new container starts

  # Force creation of the landscape role with password we set so it doesn't get autoset
  prog=$(find /usr/lib/postgresql/ -name psql)
  psqlconn="${prog} -t -A -h ${DB_HOST} -p ${DB_PORT} -U ${DB_ADMIN_USER} -d ${DB_NAME} -w"
  if [[ "`${psqlconn} -c \"SELECT rolname FROM pg_roles where rolname='${DB_LANDSCAPE_USER}';\"`" == "" ]]; then
    printf "Creating landscape user\n"
    [[ "`${psqlconn} -c \"CREATE ROLE $DB_LANDSCAPE_USER with password '${DB_LANDSCAPE_PASS}' LOGIN;\"`" ]] && printf "User landscape created\n"
  fi

  setup-landscape-server
}

# ----------------------------------------------------------
# Function: starts the service
# ----------------------------------------------------------
function startService {
  init
  startSyslog

  lsctl start

  if [ "$SERVICE" == "ASYNC_FRONTEND" ]; then
    tail -f /var/log/landscape-server/async-frontend.log
  elif [ "$SERVICE" == "APPSERVER" ]; then
    tail -f /var/log/landscape-server/appserver.log
  elif [ "$SERVICE" == "APISERVER" ]; then
    tail -f /var/log/landscape-server/api.log
  elif [ "$SERVICE" == "PINGSERVER" ]; then
    tail -f /var/log/landscape-server/pingserver.log
  elif [ "$SERVICE" == "JOBHANDLER" ]; then
    tail -f /var/log/landscape-server/job-handler.log
  elif [ "$SERVICE" == "MSGSERVER" ]; then
    tail -f /var/log/landscape-server/message-server.log
  elif [ "$SERVICE" == "PACKAGEUPLOADSERVER" ]; then
    tail -f /var/log/landscape-server/package-upload.log
  elif [ "$SERVICE" == "PACKAGEUPLOADSERVER" ]; then
    tail -f /var/log/landscape-server/package-upload.log
  elif [ "$SERVICE" == "CRON" ]; then
    cron -f
  else
    tail -f /etc/landscape/service.conf
  fi
}

# ----------------------------------------------------------
# Starts the service
# ----------------------------------------------------------

# tail -f /etc/landscape/service.conf

if [ "$SERVICE" == "UPGRADE" ]; then
  upgradeSchema
else
  startService
fi

#!/bin/bash
set -e

echo >&2 "Setting Permissions:"
ocpath='/var/www/html'
htuser='www-data'

chown -R root:${htuser} ${ocpath}/
chown -R ${htuser}:${htuser} ${ocpath}/*

if [ -n "$MYSQL_PORT_3306_TCP" ]; then
  if [ -z "$OWNCLOUD_DB_HOST" ]; then
    OWNCLOUD_DB_HOST='mysql'
  else
    echo >&2 'warning: both OWNCLOUD_DB_HOST and MYSQL_PORT_3306_TCP found'
    echo >&2 "  Connecting to OWNCLOUD_DB_HOST ($OWNCLOUD_DB_HOST)"
    echo >&2 '  instead of the linked mysql container'
  fi
fi

if [ -z "$OWNCLOUD_DB_HOST" ]; then
  echo >&2 'error: missing OWNCLOUD_DB_HOST and MYSQL_PORT_3306_TCP environment variables'
  echo >&2 '  Did you forget to --link some_mysql_container:mysql or set an external db'
  echo >&2 '  with -e OWNCLOUD_DB_HOST=hostname:port?'
  exit 1
fi

# if we're linked to MySQL, and we're using the root user, and our linked
# container has a default "root" password set up and passed through... :)
: ${OWNCLOUD_DB_USER:=root}
if [ "$OWNCLOUD_DB_USER" = 'root' ]; then
  : ${OWNCLOUD_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
fi
: ${OWNCLOUD_DB_NAME:=owncloud}

if [ -z "$OWNCLOUD_DB_PASSWORD" ]; then
  echo >&2 'error: missing required OWNCLOUD_DB_PASSWORD environment variable'
  echo >&2 '  Did you forget to -e OWNCLOUD_DB_PASSWORD=... ?'
  echo >&2
  echo >&2 '  (Also of interest might be OWNCLOUD_DB_USER and OWNCLOUD_DB_NAME.)'
  exit 1
fi

if ! [ -e index.php ]; then
  echo >&2 "Owncloud not found in $(pwd) - copying now..."
  tar cf - --one-file-system -C /usr/src/owncloud . | tar xf -
  echo >&2 "Complete! OwnCloud has been successfully copied to $(pwd)"
fi

if [ ! -e config/config.php ]; then
  : ${OWNCLOUD_ADMIN:=admin}

  if [ -z ${OWNCLOUD_ADMIN_PASSWORD+x} ]; then
    OWNCLOUD_ADMIN_PASSWORD=`openssl rand -base64 32`
    echo >&2 "Generated OwnCloud admin password: $OWNCLOUD_ADMIN_PASSWORD"
  fi

  for ((i=0;i<10;i++))
  do
    DB_CONNECTABLE=$(mysql -u$OWNCLOUD_DB_USER -p$OWNCLOUD_DB_PASSWORD -h$OWNCLOUD_DB_HOST -e 'status' >/dev/null 2>&1; echo "$?")
    if [[ DB_CONNECTABLE -eq 0 ]]; then
      exit 0
    fi
    sleep 1
  done

  sudo -u www-data php occ maintenance:install \
    --database "mysql" \
    --database-name ${OWNCLOUD_DB_NAME} \
    --database-host ${OWNCLOUD_DB_HOST} \
    --database-user ${OWNCLOUD_DB_USER} \
    --database-pass ${OWNCLOUD_DB_PASSWORD} \
    --admin-user ${OWNCLOUD_ADMIN} \
    --admin-pass ${OWNCLOUD_ADMIN_PASSWORD} \
    --no-interaction

  if [ -n ${ROOT_URL} ]; then
    echo >&2 "Adding ROOT_URL $ROOT_URL to config.php"
    sed -i "s/localhost/$ROOT_URL/g" config/config.php
  fi 
fi

exec "$@"


#!/bin/bash

set -e

uid=$(stat -c %u /app)
gid=$(stat -c %g /app)

if [ $uid == 0 ] && [ $gid == 0 ]; then
    exec "$@"
fi

if [ "$uid" != "$(id -u www-data)" ]; then
    usermod -u $uid www-data
fi

if [ "$gid" != "$(id -g www-data)" ]; then
    groupmod -g $gid www-data
fi


if [[ "$1" = 'supervisord' || "$1" = 'supervisorctl' || "$1" = 'phpenmod' || "$1" = 'phpdismod' ]]; then
    exec "$@"
fi

exec gosu www-data "$@"

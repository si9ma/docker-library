#!/bin/sh

if [ "$1" = 'redis' ]; then

    if [ "$CLUSTER_MOD" = "true" ]; then
        cp /redis-conf/redis-cluster.tmpl /usr/local/etc/redis/redis.conf
    else
        cp /redis-conf/redis.tmpl /usr/local/etc/redis/redis.conf
    fi
    redis-server /usr/local/etc/redis/redis.conf
else
  exec "$@"
fi
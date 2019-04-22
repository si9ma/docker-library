# Build from commits based on redis:5
FROM redis:5.0.4-alpine

RUN apk add --no-cache \
            # bash for docker-entrypoint.sh
            bash \ 
            # bind-tools for dig
            bind-tools

COPY redis-cluster.tmpl /redis-conf/redis-cluster.tmpl
COPY redis.tmpl /redis-conf/redis.tmpl
RUN mkdir -p /usr/local/etc/redis/ /var/log/redis/

# Add startup script
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod 755 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["redis-server"]
#!/usr/bin/env bash
# Created At Sun Apr 21 2019 12:26:13 PM 
# redis cluster builder script
# 
# Copyright 2019 si9ma <hellob374@gmail.com>

check_need() {
    for need in $@ 
    do
        command -v $need > /dev/null 2>&1 || (echo "Please Install $need" && exit 1)
    done
}

# get swarm tasks's ip
get_redis_ip() {
    local service_name="$1"
    for item in `docker service ps -f "desired-state=running" --quiet $service_name`
    do
        res=`docker inspect $item | jq -r ".[] | (.NodeID + \" \" + (.NetworksAttachments | map(select(.Network.Spec.Name == \"${stack}_net\")) | .[] | .Addresses | .[]))"`
        echo $res | grep -o -P "^.*(?=/)" # remove network mask: 127.0.0.1/24 => 127.0.0.1
    done
}

ip="$1"
stack="$2"
[ "$ip" = "" -o "$stack" = "" ] && echo "usage:$0 <ip> <swarm_stack_name>" && exit 1

check_need "docker" "docker-compose" "jq"

# build image
docker-compose build

# init swarm
docker swarm init --advertise-addr=$ip && echo -e "\nPlease run above command on another server, then enter any key to continue" && read || exit 1

# deploy
docker stack deploy --compose-file=docker-compose.yml $stack

redis_ips=`get_redis_ip "${stack}_redis" | sort -k1 | awk '{print $2}'` # all ip of redis 

# cluster 
IFS=' '
for item in `echo $redis_ips | xargs`
do
    servers="${servers}$item:6379 "
done

cmd="redis-cli --cluster create $servers --cluster-replicas 1"
echo $cmd
sleep 10 # wait 10s
docker run --network ${stack}_net --rm -it si9ma/redis:5 bash -c "$cmd" # setup
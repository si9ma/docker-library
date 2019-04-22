#!/bin/bash
set -e

# tail log 
tail_log() {
    tail -f /var/log/redis/redis-server.log
}

if [ "$1" = 'redis-server' ]; then
    if [ "$CLUSTERED" = "true" ]; then
        cp /redis-conf/redis-cluster.tmpl /usr/local/etc/redis/redis.conf
    else
        cp /redis-conf/redis.tmpl /usr/local/etc/redis/redis.conf
    fi

    # start redis server background
    redis-server /usr/local/etc/redis/redis.conf --daemonize yes

    [ "$CLUSTER_NODES" = "" ] && echo "[FAIL]Please SET CLUSTER_NODES environment" && exit 1
    [ "$CLUSTER_NODES" -lt 1 ] && echo "[FAIL]CLUSTER_NODES must > 0" && exit 1
    [ "$CLUSTER_NODES" -eq 1 ] && echo "[SUCCESS]Found standalone setup." && tail_log

    [ "$CLUSTER_SETUPER_SLOT" != "$SLOT" ] && echo "[SUCCESS] I'm $(hostname), I am not the setuper" && tail_log

    echo "[SETUP] I'm $(hostname), I am the setuper"
    until [ `echo "$nodes" | wc -l` -eq "$CLUSTER_NODES" ];do
        echo "sleep 3s to wait other nodes complete!" && sleep 3
        nodes=`dig tasks.$SERVICE_NAME 2>/dev/null | grep "^tasks.$SERVER_NAME" | awk '{print $5}'`
    done

    final_nodes=$nodes # some node may startup fail
    for node in $nodes 
    do
        ok=true
        if ! nc -z $node 6379;then
            ok=false
            for i in `seq 3` # retry 3 time
            do
                echo "sleep 1s to wait $node to complete" && sleep 1
                nc -z $node 6379 && ok=true && break # break when node ok
            done
        fi
        [ "$ok" = "false" ] &&  final_nodes=`echo $nodes | grep -v $node` && echo "$node may setup fail, give up it."
    done

    oneline_nodes=`sed -e 's/$/:6379/' <(echo "$final_nodes") | xargs`
    echo "cluster nodes: $oneline_nodes"
    redis-cli --cluster create $oneline_nodes --cluster-replicas 1 <<< "yes" # set up cluster

    echo "[SUCCESS] setup cluster successfuly!"
    tail_log
else
  exec "$@"
fi
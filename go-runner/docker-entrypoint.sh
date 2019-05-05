#!/usr/bin/env bash
# Created At Fri May 03 2019 10:13:40 PM 
# 
# Copyright 2019 si9ma <hellob374@gmail.com>

case $MODE in
DEBUG)
    dlv debug --headless --listen=:2345 --api-version=2 --accept-multiclient $@
    ;;
TEST)
    pkg="$1" method="$2"
    extra="$pkg"
    [ "$method" != "" ] && extra="--run ^$method$ $extra"
    cmd="go test -v $extra"
    eval $cmd
    ;;
TEST_DEBUG)
    pkg="$1" method="$2"
    extra="--build-flags=\"$pkg\" -- -test.v "
    [ "$method" != "" ] && extra="$extra --test.run ^$method$"
    cmd="dlv test --headless --listen=:2345 --api-version=2 --accept-multiclient $extra"
    eval $cmd
    ;;
RUN)
    go run $@
    ;;
*)
    $@ 
    ;;
esac

exit 0
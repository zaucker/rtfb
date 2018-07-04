#!/bin/bash

export RTHOME=$HOME/opt/picit/rt442

PORT=8520
if [ $1 ]; then
    PORT=$1
fi

echo "Starting rtfb on port $PORT"

export MOJO_MODE=development
export MOJO_LOG_LEVEL=debug
exec ./rtfb.pl prefork --listen "http://*:$PORT"

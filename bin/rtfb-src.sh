#!/bin/bash

export RTHOME=$HOME/opt/picit/rt442

PORT=$1
if [ $PORT ]; then
    echo "Starting rtfb on port '$1'"
else
    echo "Starting rtfb on default port. Usage: $0 (port)"
    PORT=7867
fi

export MOJO_MODE=development
export MOJO_LOG_LEVEL=debug
exec ./rtfb.pl prefork --listen "http://*:$PORT"

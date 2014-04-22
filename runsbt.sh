#!/bin/bash
if [[ -z "$1" ]]; then
    SCREENAME="sbt"
else
    SCREENAME=$1
fi
mkdir -p /tmp/sbtout
screen -d -m -S $SCREENAME
screen -S $SCREENAME -p 0 -X logfile /tmp/sbtout/${SCREENAME}out
screen -S $SCREENAME -p 0 -X log on
screen -S $SCREENAME -p 0 -X stuff "sbt
"


#!/bin/bash
if [[ -z "$1" ]]; then
    SCREENAME="sbt"
else
    SCREENAME=$1
fi
if [[ -z "$2" ]]; then
    COMMAND="compile"
else
    COMMAND=$2
fi
OUT=/tmp/sbtout/${SCREENAME}out
screen -S $SCREENAME -p 0 -X log off
[ -e $OUT ] && rm $OUT
screen -S $SCREENAME -p 0 -X log on
screen -S $SCREENAME -p 0 -X stuff "${COMMAND}
"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
perl $DIR/sbtout.pl 0 $OUT

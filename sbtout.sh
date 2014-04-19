#!/bin/bash
OUT=/tmp/sbtout #should be a param
wc -l $OUT | sed 's/[^0-9]*//g' > /tmp/sbtlastcnt #TODO have something uniq here to be able to run different sbts
screen -S sbt -p 0 -X stuff "compile
" #TODO make name of screen session unique
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
perl $DIR/sbtout.pl `cat /tmp/sbtlastcnt` $OUT

#!/bin/bash

# The Star jar
export STAR_JAR=./lib/star100.jar

# Java vm options for running star
export STAR_VMOPTS="-Xmx1g -XX:MaxPermSize=512M -Xss64m -XX:-DoEscapeAnalysis"

# Star command-line options
export STAR_CMD_OPTS="-DTARGET=starcode"

export SOURCE=

export CMDARGS=

# set -x

while [ $# -ne 0 ]
  do
    case $1 in
        -V*) STAR_JAR=~/lib/star${1:2}.jar; shift;;
        -D*) STAR_CMD_OPTS="$STAR_CMD_OPTS $1"; shift;;
        -X*) STAR_VMOPTS="$STAR_VM_OPTS $1"; shift;;
        *) break;;
    esac
  done

export STAR_OPTS="$STAR_VMOPTS $STAR_CMD_OPTS"

java $STAR_OPTS -jar $STAR_JAR $*


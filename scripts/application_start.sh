#!/bin/bash

set -e
now=$(date +'%Y-%m-%d-%H-%M-%S')
echo "application start (scripts directory)  $now" > /tmp/run.log
java -jar /var/run/app.jar

#!/bin/bash

set -e
now=$(date +'%Y%m%d%H%M%S')
echo "before install (scripts directory)  $now" > /tmp/run.log
java -jar /var/run/demo-batch-0.0.1-SNAPSHOT.jar

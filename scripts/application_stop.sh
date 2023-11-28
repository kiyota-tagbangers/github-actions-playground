#!/bin/bash

set -e
now=$(date +'%Y-%m-%d-%H-%M-%S')

rm -f /tmp/run.log

touch /tmp/run.log

chmod 777 /tmp/run.log

if [ ! -d /appllication ]; then
  echo "application stop (scripts directory)  $now" >> /tmp/run.log
  exit 0
fi
#!/bin/bash

set -e
now=$(date +'%Y-%m-%d-%H-%M-%S')

touch ~/sample-after-install.txt

if [ ! -d /appllication ]; then
  echo "after install (scripts directory)  $now" >> /tmp/run.log
  exit 0
fi
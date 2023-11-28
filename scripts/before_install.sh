#!/bin/bash

set -e
now=$(date +'%Y-%m-%d-%H-%M-%S')

if [ ! -d /appllication ]; then
  echo "/appllication does not exist" >> /tmp/run.log
  echo "before install (scripts directory)  $now" >> /tmp/run.log
  exit 0
fi
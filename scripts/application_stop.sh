#!/bin/bash

set -e
now=$(date +'%Y-%m-%d-%H-%M-%S')

if [ ! -d /appllication ]; then
  echo "application stop (scripts directory)  $now" >> /tmp/run.log
  exit 0
fi
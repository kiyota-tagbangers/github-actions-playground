#!/bin/bash

set -e


if [ ! -d /appllication ]; then
  touch /tmp/application_stop.log
  now=$(date +'%Y-%m-%d-%H-%M-%S')
  echo $now >> /tmp/application_stop.log
  chmod 777 /tmp/application_stop.log
  exit 0
fi


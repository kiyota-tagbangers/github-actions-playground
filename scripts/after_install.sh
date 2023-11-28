#!/bin/bash

set -e

if [ ! -d /appllication ]; then
  touch /tmp/after_install.log
  now=$(date +'%Y-%m-%d-%H-%M-%S')
  echo $now >> /tmp/after_install.log
  exit 0
fi
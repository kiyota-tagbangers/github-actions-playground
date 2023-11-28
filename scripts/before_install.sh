#!/bin/bash

set -e
now=$(date +'%Y-%m-%d-%H-%M-%S')

# ユーザを切り替えても意味がなかった
# sudo su - batch-sample
# touch ~/sample-before-install.txt

if [ ! -d /appllication ]; then
  echo "/appllication does not exist" >> /tmp/run.log
  echo "before install (scripts directory)  $now" >> /tmp/run.log
  exit 0
fi
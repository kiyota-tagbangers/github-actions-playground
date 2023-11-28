#!/bin/bash

set -e
now=$(date +'%Y-%m-%d-%H-%M-%S')

# ユーザを切り替えても意味がなかった
# sudo su - batch-sample
# touch ~/sample-before-install.txt

if [ ! -d /appllication ]; then
  touch /tmp/before_install.log
  now=$(date +'%Y-%m-%d-%H-%M-%S')
  echo $now >> /tmp/before_install.log
  exit 0
fi
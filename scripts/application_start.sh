#!/bin/bash

set -e


now=$(date +'%Y-%m-%d-%H-%M-%S')
echo $now >> /tmp/application_start.log

# linux コマンドでユーザを切り替えても意味がなかった
# sudo su - batch-sample
java -jar /var/run/app.jar

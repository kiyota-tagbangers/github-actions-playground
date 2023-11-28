#!/bin/bash

set -e

ls -l /tmp/run.log >> /tmp/run-log-persission.txt

now=$(date +'%Y-%m-%d-%H-%M-%S')
echo "application start (scripts directory)  $now" >> /tmp/run.log

# ユーザを切り替えても意味がなかった
# sudo su - batch-sample
java -jar /var/run/app.jar

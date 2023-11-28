#!/bin/bash

set -e


now=$(date +'%Y-%m-%d-%H-%M-%S')
ls -l /tmp/run.log >> /tmp/run-log-persission.txt
# ファイルの権限を変えられていない
# [root@ip-10-0-101-233 ~]# cat /tmp/run-log-persission.txt
# -rw-r--r--. 1 root root 140 Nov 28 13:09 /tmp/run.log
# echo "application start (scripts directory)  $now" >> /tmp/run.log
echo "application start (scripts directory)  $now" >> /tmp/application_start.log

# ユーザを切り替えても意味がなかった
# sudo su - batch-sample
java -jar /var/run/app.jar

#! /bin/bash

if test -n "$(find  -maxdepth 1 -name '*.log' -print -quit)"; then
rm *.log
fi
timedatectl
sleep 1
timedatectl set-ntp no
sleep 1
timedatectl set-time 2024-06-10
sleep 1
touch touch datasetnavigator.log
echo "---=datasetnavigator.log=---" >> datasetnavigator.log
timedatectl set-ntp yes
sleep 2
timedatectl

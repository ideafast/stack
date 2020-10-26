#!/bin/sh
now=$(date)
printf "%s\n" "$now"
date >> ~/cronjobname.txt
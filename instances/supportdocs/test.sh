#!/bin/sh
now=$(date)
printf "%s\n" "$now"
now >> ~/cronjobname.txt
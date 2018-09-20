#!/bin/bash
yum update -y
#yum install httpd php php-mysql amazon-efs-utils -y

# Mount Data Disk
mkdir -p /mnt/data
mount /dev/xvdb /mnt/data/

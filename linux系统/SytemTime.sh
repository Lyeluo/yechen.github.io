#!/usr/bin/env bash

yum install -y ntpdate

ntpdate ntp1.aliyun.com

hwclock --systohc

date -R

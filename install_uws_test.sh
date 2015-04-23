#!/usr/bin/env bash

# This script installs a simple httperf/autobench based test machine
# for testing uws performance.
# To be run by root or as a privileged user: sudo ./install_uws_test.sh
# On a freshly provisioned ec2 instance based on RightImage_CentOS_6.5_x64_v14.1.3.1
# 

sudo yum -y update
wget ftp://fr2.rpmfind.net/linux/dag/redhat/el6/en/x86_64/dag/RPMS/httperf-0.9.0-1.el6.rf.x86_64.rpm
sudo yum --nogpgcheck -y install ./httperf-0.9.0-1.el6.rf.x86_64.rpm
wget https://atyu30.googlecode.com/files/autobench-2.1.2-1.el6.x86_64.rpm
sudo yum --nogpgcheck -y install ./autobench-2.1.2-1.el6.x86_64.rpm

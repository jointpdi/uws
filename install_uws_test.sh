#!/usr/bin/env bash

# This script installs a simple httperf/autobench based test machine
# for testing uws performance.
# To be run by root or as a privileged user: sudo ./install_uws_test.sh
# On a freshly provisioned ec2 instance based on RightImage_CentOS_6.5_x64_v14.1.3.1
# 

yum -y update
#yum -y groupinstall "Development Tools"
#sed -i 's/1024/65535/' /usr/include/bits/typesizes.h
#wget http://pkgs.fedoraproject.org/repo/extras/httperf/httperf-0.9.0.tar.gz/2968c36b9ecf3d98fc1f2c1c9c0d9341/httperf-0.9.0.tar.gz
#tar xzvf httperf-0.9.0.tar.gz
#mkdir build
#cd build
#../httperf-0.9.0/configure --enable-debug
#make
#make install
#ln -s /usr/local/bin/httperf /bin/httperf
# wget ftp://fr2.rpmfind.net/linux/dag/redhat/el6/en/x86_64/dag/RPMS/httperf-0.9.0-1.el6.rf.x86_64.rpm
wget https://drive.google.com/uc?id=0B4wQsyDtMAN-NGNpczNVNXBOa3M -O httperf-0.9.0-1p1.el6.x86_64.rpm
sudo yum --nogpgcheck -y install ./httperf-0.9.0-1p1.el6.x86_64.rpm
wget https://atyu30.googlecode.com/files/autobench-2.1.2-1.el6.x86_64.rpm
yum --nogpgcheck -y install ./autobench-2.1.2-1.el6.x86_64.rpm
# Create a httperf trace at wlog.log that iterate from /1/, /2/, to /100000/
for i in {1..10000}; do echo /$i/ >>urls.log; done
tr "\n" "\0" < urls.log > wlog.log
ulimit -n 16384


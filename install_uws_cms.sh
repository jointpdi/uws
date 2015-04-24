#!/usr/bin/env bash

# This script installs a simple django based webapp to be used
# as a cms machine for testing uws performance.
# To be run by root or as a privileged user: sudo ./install_uws_cms.sh
# On a freshly provisioned ec2 instance based on RightImage_CentOS_6.5_x64_v14.1.3.1
# 

# change this before running
OS_USERNAME=uws
OS_PASSWORD=changeme
APP_NAME=uws_cms

yum -y update
yum -y install httpd mod_wsgi python-setuptools lynx

pass=`python -c "import crypt; print crypt.crypt('$OS_PASSWORD','saltme')"`
# Create user account and home dir
useradd -d /home/uws -s /bin/bash -p $pass uws
chmod 755 /home/uws

# Install django
wget https://www.djangoproject.com/download/1.4.20/tarball/ -O Django-1.4.20.tar.gz
tar xzvf Django-1.4.20.tar.gz
cd Django-1.4.20
python setup.py install
cd ../

## Create file directories and set permissions
#mkdir -p /tmp
#chgrp apache /tmp
#chmod 777 /tmp

## Setup name based vhost
cat <<EOF> /etc/httpd/conf.d/$APP_NAME.conf
#WSGIDaemonProcess $OS_USERNAME user=$OS_USERNAME group=$OS_USERNAME processes=49 threads=1 maximum-requests=10000
#WSGIProcessGroup $OS_USERNAME
WSGIScriptAlias / /home/$OS_USERNAME/$APP_NAME/wsgi/$APP_NAME.wsgi
EOF

cd /home/$OS_USERNAME
django-admin.py startproject $APP_NAME

## Create wsgi file
mkdir -p /home/$OS_USERNAME/$APP_NAME/wsgi/
touch /home/$OS_USERNAME/$APP_NAME/wsgi/$APP_NAME.wsgi
cat <<EOF> /home/$OS_USERNAME/$APP_NAME/wsgi/$APP_NAME.wsgi
import os, sys
path = '/home/$OS_USERNAME/$APP_NAME'
if path not in sys.path:
    sys.path.append(path)

os.environ['DJANGO_SETTINGS_MODULE'] = '$APP_NAME.settings'

import django.core.handlers.wsgi
application = django.core.handlers.wsgi.WSGIHandler()
EOF

# checkout code to home/uws/uws_cms
cat <<EOF> /home/$OS_USERNAME/$APP_NAME/$APP_NAME/views.py
from django.http import HttpResponse, HttpResponseServerError
import datetime
from random import randint
def hello(request):
    if randint(0,1):
        return HttpResponse("<html>Current Time is " + datetime.datetime.now().isoformat('T') +"</html>" )
    else:
        return HttpResponseServerError("<html>Server Error!</html>" )
    
EOF

rm /home/$OS_USERNAME/$APP_NAME/$APP_NAME/urls.py
touch /home/$OS_USERNAME/$APP_NAME/$APP_NAME/urls.py
cat <<EOF> /home/$OS_USERNAME/$APP_NAME/$APP_NAME/urls.py
from django.conf.urls import patterns, include, url
from uws_cms.views import hello

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('',
    url(r'^$', hello),
    # Examples:
    # url(r'^/$', 'uws_cms.views.home', name='home'),
    # url(r'^uws_cms/', include('uws_cms.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
)
EOF

chown -R $OS_USERNAME /home/$OS_USERNAME
chgrp -R $OS_USERNAME /home/$OS_USERNAME
chmod -R 755 /home/$OS_USERNAME/$APP_NAME

service httpd start

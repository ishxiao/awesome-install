#!/bin/bash
# author: Xiao Shang
# note: Deploy a Flask Website on Nginx with uWSGI
# ref url: https://www.vultr.com/docs/deploy-a-flask-website-on-nginx-with-uwsgi
# chmod +x ./i*.sh
# sudo sh i*.sh

LOG_FILE=flask_install_log.txt
exec 3>&1 1>>${LOG_FILE} 2>&1 # Writing outputs to log file(log.txt)

echo "Deploy a Flask Website on Nginx with uWSGI." 1>&3
echo "ref: https://www.vultr.com/docs/deploy-a-flask-website-on-nginx-with-uwsgi" 1>&3

# Website home directory
# eq: WHDIR=/var/www/example
WHDIR=/var/www/ishx

# Server names
# eq:
# SERVERNAME=192.0.2.123
# SERVERNAME="example.com www.example.com"
# SERVERNAME=localhost
# If you do not have a registered domain name,
# use localhost for server_name in place of example.com and www.example.com.
SERVERNAME=localhost

#
echo "Preparing step: update and upgrade." 1>&3
apt update && apt upgrade -y

echo "5 steps." 1>&3

echo "Step 1. Install Nginx." 1>&3

apt install nginx -y

echo "Step 2. Set up Flask and uWSGI." 1>&3

echo "Install uWSGI and Flask." 1>&3

apt install build-essential python3 -y

apt install python3-pip python3-dev -y

# fixed "rebuild uwsgi with pcre support"
apt install libpcre3 libpcre3-dev -y

pip3 install uwsgi flask

echo "Create a website home directory." 1>&3

echo "Default: ${WHDIR}." 1>&3

mkdir ${WHDIR}

# cp -r main.py /var/www/ishx/main.py

echo "Create a minimal Flask application main.py in ${WHDIR}." 1>&3 

echo "#!/usr/bin/env python3
from flask import Flask
app = Flask(__name__)

@app.route("\""/"\"")
def index():
    return "\""Hello World!"\""

if __name__ == "\""__main__"\"":
    app.run(host="\""0.0.0.0"\"")" > ${WHDIR}/main.py

# cp -r config-uwsgi.ini /var/www/ishx/config-uwsgi.ini

echo "Create config-uwsgi.ini in ${WHDIR}." 1>&3 

echo "[uwsgi]

app = main
module = %(app)
callable = app

socket = ${WHDIR}/ishx.sock
chdir = ${WHDIR}
chmod-socket = 666

processes = 4
die-on-term = true" > ${WHDIR}/config-uwsgi.ini

echo "Step 3. Set up Nginx." 1>&3

rm /etc/nginx/sites-enabled/default

# cp -r config-nginx.conf /var/www/ishx/config-nginx.conf

echo "server {

    listen 80;
    listen [::]:80;

    server_name ${SERVERNAME};

    location / {
        include uwsgi_params;
        uwsgi_pass unix:${WHDIR}/ishx.sock;
    }
}
" > ${WHDIR}/config-nginx.conf

ln -s ${WHDIR}/config-nginx.conf /etc/nginx/conf.d/

systemctl restart nginx

echo "Step 4. Run uWSGI as service with emperor" 1>&3

# nohup uwsgi /var/www/ishx/config-uwsgi.ini &

# cp -r emperor.uwsgi.service /etc/systemd/system/emperor.uwsgi.service
# cp -r emperor.uwsgi.service /etc/systemd/system/emperor.uwsgi.socket

echo "Create /etc/systemd/system/emperor.uwsgi.service." 1>&3 

echo "[Unit]
Description=uWSGI Emperor
After=syslog.target

[Service]
ExecStart=/usr/local/bin/uwsgi --ini /etc/uwsgi/emperor.ini
# Requires systemd version 211 or newer
RuntimeDirectory=uwsgi
Restart=always
KillSignal=SIGQUIT
Type=notify
StandardError=syslog
NotifyAccess=all

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/emperor.uwsgi.service

mkdir /etc/uwsgi/

# cp emperor.ini /etc/uwsgi/emperor.ini

echo "Create /etc/uwsgi/emperor.ini." 1>&3

echo "[uwsgi]
emperor = /etc/uwsgi/vassals
#uid = www-data
#gid = www-data" > /etc/uwsgi/emperor.ini

mkdir /etc/uwsgi/vassals

# cp config-uwsgi.ini /etc/uwsgi/vassals/config-uwsgi.ini

ln -s ${WHDIR}/config-uwsgi.ini /etc/uwsgi/vassals/

systemctl enable emperor.uwsgi.service
systemctl start emperor.uwsgi.service

# systemctl status emperor.uwsgi.service

# systemctl stop emperor.uwsgi.service

echo "5. Install SSL Certificate." 1>&3

echo "
If you have a public domain name, configure the webserver for HTTPS with a free Let's Encrypt certificate using Certbot.
1. Install Certbot.
# apt install certbot python-certbot-nginx
2. Request an SSL certificate.
# certbot --nginx
3. Answer the questions when prompted by Certbot and agree to the terms of service.
4. Certbot will ask which domain names should have SSL support, press ENTER to select all names.
5. When prompted, choose to redirect HTTP traffic to HTTPS." 1>&3


echo "Are you sure to install SSL Certificate? [y/N]" 1>&3
read response 
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]
then
	apt install certbot python3-certbot-nginx -y
	certbot --nginx
    # certbot renew # certificate
fi

echo "Finished." 1>&3

echo "More details in ${LOG_FILE}." 1>&3

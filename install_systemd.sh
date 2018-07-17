#!/bin/sh -
filecontents=$(echo "
[Unit]
Description=imjac.in/ta webcore server
After=postgresql.service

[Service]
WorkingDirectory=`pwd`
Environment="WEBCORE_DB_URL=postgres://web:web@localhost/web"
Environemnt="RACK_ENV=production"
ExecStartPre=/bin/sleep 1
ExecStart=/usr/bin/authbind --deep `/usr/share/rvm/bin/rvm gemdir`/wrappers/thin start -p 80
Type=simple
User=www
Group=www
Restart=always

[Install]
WantedBy=multi-user.target
")

echo "$filecontents" > /etc/systemd/system/webcore.service

apt-get install authbind
touch /etc/authbind/byport/80
touch /etc/authbind/byport/443
chmod 777 /etc/authbind/byport/80
chmod 777 /etc/authbind/byport/443

systemctl daemon-reload
systemctl restart webcore.service
systemctl enable webcore.service

#!/bin/sh -
filecontents=$(echo "
[Unit]
Description=imjac.in/ta webcore server

[Service]
WorkingDirectory=`pwd`
ExecStartPre=/bin/sleep 1
ExecStart=`/usr/share/rvm/bin/rvm gemdir`/wrappers/thin start -p 80
Type=simple
User=www
Group=www
Restart=always

[Install]
WantedBy=multi-user.target
")

echo "$filecontents" > /etc/systemd/system/webcore.service
systemctl daemon-reload
systemctl restart webcore.service
systemctl enable webcore.service

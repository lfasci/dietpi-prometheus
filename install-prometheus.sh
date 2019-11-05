#!/bin/bash
prometheus_VERSION="2.13.1"
CONFIGDIR="/etc/prometheus"
USER="prometheus"
wget https://github.com/prometheus/prometheus/releases/download/v${prometheus_VERSION}/prometheus-${prometheus_VERSION}.linux-armv7.tar.gz
tar -xvzf prometheus-${prometheus_VERSION}.linux-armv7.tar.gz
cd prometheus-${prometheus_VERSION}.linux-armv7

# create user
useradd --no-create-home --shell /bin/false $USER 

# create directories
mkdir $CONFIGDIR/prometheus
mkdir -p /var/lib/prometheus/data

# Copy sample config file
cp prometheus.yml $CONFIGDIR/prometheus/

# copy binaries
cp prometheus /usr/local/bin/
cp promtool /usr/local/bin/
cp tsdb /usr/local/bin/

#Copy console files
cp -r consoles /etc/prometheus
cp -r console_libraries /etc/prometheus

# set ownership
chown -R $USER:$USER $CONFIGDIR/prometheus
chown -R $USER:$USER /var/lib/prometheus
chown $USER:$USER /usr/local/bin/prometheus
chown $USER:$USER /usr/local/bin/promtool
chown $USER:$USER /usr/local/bin/tsdb

# setup systemd
echo "[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/prometheus.service

systemctl daemon-reload
systemctl enable prometheus
# systemctl start prometheus

echo "Setup complete.
Edit you settings in  $CONFIGDIR/prometheus/prometheus.yml"


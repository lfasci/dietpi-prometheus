#!/bin/bash
NODEXPORTER_VERSION="0.18.1"
CONFIGDIR="/etc/prometheus"
USER="prometheus"
wget https://github.com/prometheus/node_exporter/releases/download/v${NODEXPORTER_VERSION}/node_exporter-${NODEXPORTER_VERSION}.linux-armv7.tar.gz
tar -xvzf node_exporter-${NODEXPORTER_VERSION}.linux-armv7.tar.gz
cd node_exporter-${NODEXPORTER_VERSION}.linux-armv7

# create user
#useradd --no-create-home --shell /bin/false node_exporter 

# copy binaries
cp node_exporter /usr/local/bin/

# set ownership
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# setup systemd
echo "[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/node_exporter.service

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

echo "Setup complete.
Edit you settings in  $CONFIGDIR/node_exporter/node_exporter.yml:
Add the following rows in /etc/prometheus/prometheus.yml:

- job_name: node
  static_configs:
    - targets: ['localhost:9100']
restart both services: node_exporter and prometheus "


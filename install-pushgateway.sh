#!/bin/bash
PUSHGATEWAY_VERSION="1.0.0"
CONFIGDIR="/etc/prometheus"
USER="prometheus"
wget https://github.com/prometheus/pushgateway/releases/download/v${PUSHGATEWAY_VERSION}/pushgateway-${PUSHGATEWAY_VERSION}.linux-armv7.tar.gz
tar -xvzf pushgateway-${PUSHGATEWAY_VERSION}.linux-armv7.tar.gz
cd pushgateway-${PUSHGATEWAY_VERSION}.linux-armv7

# create user
# useradd --no-create-home --shell /bin/false prometheus 

# copy binaries
cp pushgateway /usr/local/bin/

# set ownership
chown $USER:$USER /usr/local/bin/pushgateway

# setup systemd
echo "[Unit]
Description=Prometheus Push Gateway
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/pushgateway \
    --log.level=\"info\" \
    --log.format=\"logger:stdout?json=true\"

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/pushgateway.service

systemctl daemon-reload
systemctl enable pushgateway
systemctl start pushgateway

echo "Setup complete.
Add the following rows in /etc/prometheus/prometheus.yml:
- job_name: pushgateway
  honor_labels: true
  static_configs:
   - targets: ['localhost:9091']
restart prometheus "


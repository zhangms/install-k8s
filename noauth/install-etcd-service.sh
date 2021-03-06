#!/bin/bash

serviceName=etcd

function create_serviceFile() {
    mkdir -p /var/lib/etcd/
    str="[Unit] \n
         Description=Extcd Server\n
         After=network.target\n
         After=network-online.target\n
         Wants=network-online.target\n\n[Service]\n
         Type=notify\n
         WorkingDirectory=/var/lib/etcd/\n
         EnvironmentFile=-/etc/etcd/etcd.conf\n
         ExecStart=/usr/local/bin/etcd \$ETCD_OPTIONS\n
         Restart=on-failure\n
         RestartSec=5\n
         LimitNOFILE=65536\n\n[Install]\n
         WantedBy=multi-user.target\n"
    echo -e $str > /usr/lib/systemd/system/${serviceName}.service
}

function createConfigFile() {
    mkdir /etc/etcd/
    echo "" > /etc/etcd/etcd.conf
}

create_serviceFile
createConfigFile
systemctl daemon-reload
systemctl disable
systemctl enable ${serviceName}
systemctl restart ${serviceName}
systemctl status ${serviceName}


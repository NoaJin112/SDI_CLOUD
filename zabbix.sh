#!/bin/bash
host=$(hostname)
ip=$hostname -I | awk '{print $1}'

ufw allow 10050

wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu22.04_all.deb
dpkg -i zabbix-release_7.0-2+ubuntu22.04_all.deb
apt update 

apt install zabbix-agent -y

systemctl restart zabbix-agent
systemctl enable zabbix-agent

sed -i "s/Server=127.0.0.1/Server=10.24.32.50/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=10.24.32.50/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/Hostname=Zabbix server/Hostname=$host/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/# HostMetadata=/HostMetadata=welkom/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/# HostInterface=/HostInterface=$ip/" /etc/zabbix/zabbix_agentd.conf

systemctl restart zabbix-agent

host=$(hostname)
ip=$(hostname -I)

sudo ufw allow 10050

sudo wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_7.0-2+ubuntu22.04_all.deb
sudo apt update 

sudo apt install zabbix-agent -y

sudo systemctl restart zabbix-agent
sudo systemctl enable zabbix-agent

sed -i "s/Server=127.0.0.1/Server=10.24.32.50/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=10.24.32.50/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/Hostname=Zabbix server/Hostname=$host/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/# HostMetadata=/HostMetadata=welkom/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/# HostInterface=/HostInterface=$ip/" /etc/zabbix/zabbix_agentd.conf

systemctl restart zabbix-agent

#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

# Install Dependencies
printf "Installing Dependencies\n"
apt update
apt install curl wget unbound unbound-anchor logrotate ntp -y

printf "Configuring Unbound\n"
mkdir -p /var/log/unbound
touch /var/log/unbound/unbound.log
cp ./configs/unbound /etc/logrotate.d/
cp ./configs/pi-hole.conf /etc/unbound/unbound.conf.d/
cp ./configs/forwardFailed /bin
wget -O "/usr/share/dns/root.zone" "https://www.internic.net/domain/root.zone"
wget -O "/usr/share/dns/root.hints" "https://www.internic.net/domain/named.root"
chmod +x /etc/logrotate.d/unbound
chmod +x /bin/forwardFailed
chmod -R 644 /etc/unbound/unbound.conf.d/pi-hole.conf
chown unbound /var/log/unbound/unbound.log
chown unbound /etc/unbound/root.zone
chown unbound /etc/unbound/root.hints
unbound-anchor -a /usr/share/dns/root.key
unbound-anchor -v
service unbound restart

printf "Setup Pi-hole\n"
mkdir -p /etc/pihole/
cp configs/setupVars.conf /etc/pihole/
chmod -R 644 /etc/pihole/setupVars.conf
source /etc/pihole/setupVars.conf
useradd -ms /bin/bash pi-hole && export USER=pi-hole
curl -sSL# https://install.pi-hole.net | bash -sex -- --unattended

printf "Configuring DNSMasq\n"
echo "edns-packet-max=1232" >> /etc/dnsmasq.d/99-edns.conf
chmod -R 644 /etc/dnsmasq.d/99-edns.conf

apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

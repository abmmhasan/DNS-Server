#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

# Install Dependencies
apt update
apt upgrade -y
apt install git curl unbound sudo dnsmasq  -y

echo "edns-packet-max=1232" >> /etc/dnsmasq.d/99-edns.conf
chmod -R 644 /etc/dnsmasq.d/99-edns.conf
cp configs/pihole.conf /etc/unbound/unbound.conf.d/
chmod -R 644 /etc/unbound/unbound.conf.d/pihole.conf

sudo service unbound-resolvconf stop
sudo chkconfig unbound-resolvconf off
sudo sed -Ei 's/^unbound_conf=/#unbound_conf=/' /etc/resolvconf.conf
sudo rm /etc/unbound/unbound.conf.d/resolvconf_resolvers.conf
sudo service unbound restart

mkdir -p /etc/pihole/
cp configs/setupVars.conf /etc/pihole/
chmod -R 644 /etc/pihole/setupVars.conf
source /etc/pihole/setupVars.conf
curl -sSL https://install.pi-hole.net | bash -sex -- --unattended

apt clean
sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

# Install Dependencies
sudo apt update
sudo apt upgrade -y
sudo apt install git curl -y

sudo mkdir -p /etc/pihole/
sudo cp configs/setupVars.conf /etc/pihole/
source /etc/pihole/setupVars.conf
sudo curl -sSL https://install.pi-hole.net | bash -sex -- --unattended

sudo apt install unbound -y
sudo mkdir -p /etc/unbound/unbound.conf.d/
sudo mkdir -p /etc/dnsmasq.d/
sudo touch /etc/dnsmasq.d/99-edns.conf
sudo echo "edns-packet-max=1232" >> /etc/dnsmasq.d/99-edns.conf
sudo cp configs/pihole.conf etc/unbound/unbound.conf.d/

sudo systemctl disable --now unbound-resolvconf.service
sudo sed -Ei 's/^unbound_conf=/#unbound_conf=/' /etc/resolvconf.conf
sudo rm /etc/unbound/unbound.conf.d/resolvconf_resolvers.conf

sudo service unbound restart

sudo apt clean
sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

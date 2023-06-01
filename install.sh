#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

# Install Dependencies
apt update && apt upgrade && apt install dnsmasq unbound curl -y

mkdir -p /etc/unbound/unbound.conf.d/ && mkdir -p /etc/pihole/ && mkdir -p /etc/dnsmasq.d/
touch /etc/dnsmasq.d/99-edns.conf && echo "edns-packet-max=1232" >> /etc/dnsmasq.d/99-edns.conf

cp configs/unbound.conf /etc/unbound/unbound.conf.d/
cp configs/pihole.conf etc/unbound/unbound.conf.d/
cp configs/setupVars.conf /etc/pihole/
source /etc/pihole/setupVars.conf
RUN curl -sSL https://install.pi-hole.net | bash -sex -- --unattended

sudo systemctl disable --now unbound-resolvconf.service
sudo sed -Ei 's/^unbound_conf=/#unbound_conf=/' /etc/resolvconf.conf
sudo rm /etc/unbound/unbound.conf.d/resolvconf_resolvers.conf

sudo service unbound restart

apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
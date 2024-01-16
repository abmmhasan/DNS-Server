#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

# Install Dependencies
printf "Installing Dependencies\n"
apt update
apt upgrade -y
apt install curl unbound -y

printf "Configuring Unbound\n"
cp configs/pi-hole.conf /etc/unbound/unbound.conf.d/
chmod -R 644 /etc/unbound/unbound.conf.d/pi-hole.conf
service unbound restart

printf "Setup Pi-hole\n"
mkdir -p /etc/pihole/
cp configs/setupVars.conf /etc/pihole/
chmod -R 644 /etc/pihole/setupVars.conf
source /etc/pihole/setupVars.conf
useradd -ms /bin/bash pi-hole && export USER=pi-hole
curl -sSL https://install.pi-hole.net | bash -sex -- --unattended

printf "Configuring DNSMasq\n"
echo "edns-packet-max=1232" >> /etc/dnsmasq.d/99-edns.conf
chmod -R 644 /etc/dnsmasq.d/99-edns.conf

apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

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
apt install git wget curl unbound sudo net-tools gamin sysv-rc-conf lighttpd lighttpd-mod-deflate -y

printf "Configuring Unbound\n"
cp configs/pi-hole.conf /etc/unbound/unbound.conf.d/
chmod -R 644 /etc/unbound/unbound.conf.d/pi-hole.conf
service unbound-resolvconf stop
sysv-rc-conf unbound-resolvconf off
sed -Ei 's/^unbound_conf=/#unbound_conf=/' /etc/resolvconf.conf
rm /etc/unbound/unbound.conf.d/resolvconf_resolvers.conf
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
/etc/init.d/dnsmasq restart
service network-manager restart

apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

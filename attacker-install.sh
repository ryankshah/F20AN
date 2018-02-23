#!/bin/bash

#
# This script should be run on the attacker machine.
# It will install required dependencies to carry out an attack against a victim
# running a vulnerable version of the Transmission bittorrent client.
#

set -e
cat <<EOF
# This script will install and set up this machine to server malicious webpages
# that may lead to code execution on vulnerable hosts.
#
# Press Any key to continue with installation
# Ctrl-C to cancel
EOF

read -n 1 -s

echo "-> Installing required dependencies"
sudo apt -qq update
sudo apt -y -qq install \
	qbittorrent \
	net-tools

echo "-> Setting IP to 10.0.2.30"
sudo tee -a /etc/network/interfaces > /dev/null <<EOF

auto enp0s3
iface enp0s3 inet static
	address 10.0.2.30
	netmask 255.255.255.0

EOF

sudo ifup enp0s3

# TODO:
# Need to set up qbittorrent to server torrent file...

echo "-> Starting webserver on port 80"
echo "->	(This will server the attack 'landing' page)"
echo "->	(output logged to ./http.server.80.log)"
sudo python3 -m http.server 80 > http.server.80.log 2>&1 &

echo "-> Starting webserver on port 9091"
echo "->	(This will serve the attack payload and run the exploit)"
echo "->	(output logged to ./http.server.9091.log)"
python3 -m http.server 9091 > http.server.9091.log 2>&1 &

echo "-> DONE!"

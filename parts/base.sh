#!/bin/bash
set -eu -o pipefail

apt-get -y update

# Package install
apt-get -y install \
    nano \
    vim \
    htop \
    git \
    python3-pip \
    build-essential \
    devscripts

# Add line to config.txt
echo 'VIDEO_CAMERA = "1"' >> /boot/config.txt

cat >>/boot/config.txt <<EOF
# Clear any filters that may previously have been in effect.
[all]
# Enable the serial console on pins 8 and 10.
enable_uart=1
EOF

cat >>/etc/network/interfaces <<EOF
# Bring up interface with link local address
# As DHCPCD is disabled, we can disregard the above warning
allow-hotplug eth0
iface eth0 inet manual
EOF

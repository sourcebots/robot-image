#!/bin/bash
set -eux -o pipefail

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

cat >>/etc/dhcpcd.conf <<EOF
# define a static profile to use if DHCP fails
profile static_eth0
static ip_address=172.31.254.254/24

# fallback to static profile on eth0 if DHCP fails
interface eth0
fallback static_eth0
EOF

# Set hostname
original_hostname=$(uname -n)
echo robot > /etc/hostname
hostname robot
sed -i 's/$original_hostname/robot/gi' /etc/hosts

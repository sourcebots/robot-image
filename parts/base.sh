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
    build-essential

cat >>/boot/config.txt <<EOF
# Clear any filters that may previously have been in effect.
[all]
# Enable the serial console on pins 8 and 10.
enable_uart=1
EOF

# define a static profile to use if DHCP fails
cat <<EOF > /etc/network/interfaces.d/robot_eth0
auto lo eth0 eth0:0
allow-hotplug eth0
iface lo inet loopback
iface eth0 inet dhcp

# define a static profile to use if DHCP fails
iface eth0:0 inet static
    address 172.31.254.254
    netmask 255.255.255.0
EOF
# nmcli connection modify 'Wired connection 1' +ipv4.addresses 172.31.254.254/24

# Set hostname
original_hostname=$(cat /etc/hostname)
echo robot > /etc/hostname
hostname robot
sed -i "s/$original_hostname/robot/gi" /etc/hosts

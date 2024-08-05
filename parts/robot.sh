#!/bin/bash
set -eux -o pipefail

echo "Storage=persistent" >> /etc/systemd/journald.conf

# Install and configure udiskie
apt-get install -y udiskie
cp /tmp/packer-files/udiskie/udiskie.yml /etc/
cp /tmp/packer-files/udiskie/udiskie.service /lib/systemd/system/
systemctl enable udiskie.service

# Add polkit rules for udiskie
mkdir -p /etc/polkit-1/rules.d
mkdir -p /etc/polkit-1/localauthority/50-local.d
cp /tmp/packer-files/polkit/rules.d/50-udiskie.rules /etc/polkit-1/rules.d/50-udiskie.rules
cp /tmp/packer-files/polkit/localauthority/10-udisks.pkla /etc/polkit-1/localauthority/50-local.d/10-udisks.pkla

# Create a group that can use udisks and add the default user to it.
groupadd --force storage
usermod -a -G storage robot

# Allow pip to install packages globally
sudo rm /usr/lib/python3.11/EXTERNALLY-MANAGED

# Install core components
pip install --no-cache -r /tmp/packer-files/requirements.txt

# Install helpful libraries
pip install --no-cache -r /tmp/packer-files/libraries.txt

cp /tmp/packer-files/runusb.service /lib/systemd/system/
systemctl enable runusb.service

group=plugdev

# Remove a buggy udev package that breaks the USB tree if FTDI chips are plugged into too many USB hubs
# See https://github.com/raspberrypi/linux/issues/3779#issuecomment-709481662
# and https://groups.google.com/g/linux.debian.bugs.dist/c/5jI9dDZgfUU
apt-get remove -y rpi.gpio-common

# Create a group and add the default user to it.
groupadd --force $group
usermod -a -G $group robot

# Give members of the group access to particular devices.
dir=/etc/udev/rules.d
mkdir -p $dir
cat >$dir/99-sb-kit.rules <<EOF
# SR power board v4
SUBSYSTEM=="usb", ATTRS{idVendor}=="1bda", ATTRS{idProduct}=="0010", GROUP="$group", MODE="0666"
# SR motor board v4
SUBSYSTEM=="tty", DRIVERS=="ftdi_sio", ATTRS{interface}=="MCV4B", GROUP="$group", MODE="0666"
# SR servo board v4
SUBSYSTEM=="usb", ATTRS{idVendor}=="1bda", ATTRS{idProduct}=="0011", GROUP="$group", MODE="0666"
# Reduce latency for FTDI chips to 1ms (default is 16ms)
ACTION=="add", SUBSYSTEMS=="usb-serial", DRIVERS=="ftdi_sio", ATTR{latency_timer}="1"
EOF

# Setup KCH leds triggered by systemd
cp /tmp/packer-files/leds/*.service /lib/systemd/system/
systemctl enable boot_40.service
systemctl enable boot_60.service
systemctl enable boot_80.service

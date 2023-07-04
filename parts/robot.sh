#!/bin/bash
set -eux -o pipefail

export PACKAGES_DIR=/tmp/packer-packages

echo "Storage=persistent" >> /etc/systemd/journald.conf

cd $PACKAGES_DIR/runusb
debuild -uc -us

cd $PACKAGES_DIR/usbmount
dpkg-buildpackage -us -uc -b

apt-get install -y $PACKAGES_DIR/*.deb

# Install core components
pip install --no-cache -r /tmp/packer-files/requirements.txt

# Install helpful libraries
pip install --no-cache -r /tmp/packer-files/libraries.txt

group=plugdev

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
EOF

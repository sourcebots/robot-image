#!/bin/bash
set -eux -o pipefail

echo "Storage=persistent" >> /etc/systemd/journald.conf

cd $PACKAGES_DIR/runusb
debuild -uc -us

apt-get install -y $PACKAGES_DIR/*.deb

# Install and configure udiskie
apt-get install -y udiskie
cp /tmp/packer-files/udiskie/udiskie.yml /etc/
cp /tmp/packer-files/udiskie/udiskie.service /lib/systemd/system/
systemctl enable udiskie.service

# Configure udisks2 to allow mounting as other users
mkdir -p /etc/udisks2
cat >/etc/udisks2/mount_options.conf <<EOF
### Simple global overrides
[defaults]
# common options, applied to any filesystem, always merged with specific filesystem type options
allow=uid=$(id -u robot),uid=$(id -u runusb),gid=$(id -g robot),exec,noexec,nodev,nosuid,atime,noatime,nodiratime,ro,rw,sync,dirsync,noload
EOF

# Automatically mount USB drives as the runusb user with the robot group
echo "  - options: [uid=$(id -u runusb), gid=$(id -g robot)]" >> /etc/udiskie.yml

# Make the base mount point accessible to all users
mkdir -p --mode=777 /media/root

# Install core components
pip install --no-cache -r /tmp/packer-files/requirements.txt

# Install helpful libraries
pip install --no-cache -r /tmp/packer-files/libraries.txt

cp /tmp/packer-files/runusb.service /lib/systemd/system/
systemctl enable runusb.service

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

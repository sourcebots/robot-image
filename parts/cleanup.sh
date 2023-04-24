#!/bin/bash
set -eu -o pipefail


systemctl disable dhcpcd
systemctl disable hciuart

apt-get remove --yes build-essential devscripts

apt-get autoremove --yes

pip3 cache purge

#!/bin/bash
set -eux -o pipefail

systemctl disable dhcpcd
systemctl disable hciuart

apt-get remove --yes build-essential devscripts

apt-get autoremove --yes

rm -rf $HOME/.cache

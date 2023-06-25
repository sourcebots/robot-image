#!/bin/bash
set -eux -o pipefail

systemctl disable hciuart

apt-get remove --yes devscripts

apt-get autoremove --yes

apt-get clean --yes

rm -rf $HOME/.cache /tmp/* /var/lib/apt/lists/* /var/tmp/* /var/log/*

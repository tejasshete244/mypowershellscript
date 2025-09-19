#!/bin/bash
set -ex
systemctl enable nvidia-fabricmanager

TMPDIR=$(mktemp -d)
cd $TMPDIR
curl -O https://efa-installer.amazonaws.com/aws-efa-installer-1.41.0.tar.gz
tar -xf aws-efa-installer-1.41.0.tar.gz
cd aws-efa-installer
./efa_installer.sh -y -n
cd /tmp/
rm -rf $TMPDIR
modinfo efa

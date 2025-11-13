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

# --- VALIDATION TESTS ---

echo "==== Checking NVIDIA Fabric Manager status ===="
if systemctl is-active --quiet nvidia-fabricmanager; then
    echo "✅ NVIDIA Fabric Manager is active."
else
    echo "❌ NVIDIA Fabric Manager is NOT active!"
    systemctl status nvidia-fabricmanager || true
fi

echo "==== Checking NVIDIA driver presence ===="
if nvidia-smi &>/dev/null; then
    nvidia-smi
    echo "✅ NVIDIA driver is installed and detected."
else
    echo "❌ NVIDIA driver not found."
fi

echo "==== Checking EFA installation ===="
if modinfo efa &>/dev/null; then
    echo "✅ EFA kernel module is present."
else
    echo "❌ EFA kernel module not found."
fi

if fi_info -p efa &>/dev/null; then
    echo "✅ EFA fabric provider detected by libfabric."
else
    echo "⚠️ EFA provider not detected by fi_info."
fi

echo "==== EFA RDMA verification ===="
if lsmod | grep -q efa; then
    echo "✅ EFA module loaded."
else
    echo "❌ EFA module not loaded."
fi

echo "==== EFA and NVIDIA Fabric Manager setup complete ===="

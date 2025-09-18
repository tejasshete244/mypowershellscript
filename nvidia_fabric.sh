#!/bin/bash
set -ex
systemctl enable nvidia-fabricmanager
systemctl start nvidia-fabricmanager

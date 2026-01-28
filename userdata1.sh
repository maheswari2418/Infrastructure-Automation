#!/bin/bash
# Minimal bootstrap - Ansible will configure this server
yum update -y
yum install -y python3 curl wget git

# Install Ansible
pip3 install ansible

echo "Bootstrap complete - ready for Ansible configuration"

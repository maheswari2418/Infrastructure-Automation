#!/bin/bash
# Minimal bootstrap - Ansible will configure this server
yum update -y
yum install -y nodejs npm git curl wget

# Install Ansible
pip3 install ansible

echo "Bootstrap complete - ready for Ansible configuration"

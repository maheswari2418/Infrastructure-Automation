# Ansible Deployment Guide

## Prerequisites
- Terraform infrastructure deployed
- SSH key pair configured
- Ansible 2.9+ installed
- Python 3.6+ on target servers

## File Structure
```
ansible/
├── ansible.cfg           # Ansible configuration
├── inventory.ini         # Inventory file with hosts and groups
├── group_vars/
│   ├── webservers.yml    # Web tier variables
│   └── appservers.yml    # Application tier variables
├── templates/
│   ├── httpd.conf.j2     # Apache proxy configuration
│   ├── flask_app.py.j2   # Flask application template
│   └── flask.service.j2  # Systemd service template
└── playbooks/
    ├── site.yml          # Master playbook
    ├── web.yml           # Web tier configuration
    └── app.yml           # Application tier configuration
```

## Steps to Deploy

### 1. Get Infrastructure Details from Terraform
```bash
terraform output -json > tf_output.json
```

### 2. Generate Inventory from Terraform Output
```bash
# Update ansible/inventory.ini with IPs from Terraform output:
# - WEB_SERVER_1_IP: from terraform output web_server_ips[0]
# - WEB_SERVER_2_IP: from terraform output web_server_ips[1]
# - APP_SERVER_1_IP: from terraform output app_server_ips[0]
# - APP_SERVER_2_IP: from terraform output app_server_ips[1]
```

### 3. Configure SSH Access
```bash
# Ensure SSH key has correct permissions
chmod 600 ~/.ssh/terraform.pem

# Test SSH connectivity
ssh -i ~/.ssh/terraform.pem ec2-user@<WEB_SERVER_1_IP>
```

### 4. Run Ansible Playbooks
```bash
# Validate inventory
ansible-inventory -i ansible/inventory.ini --list

# Dry run to see what will be changed
ansible-playbook -i ansible/inventory.ini ansible/playbooks/site.yml --check

# Execute deployment
ansible-playbook -i ansible/inventory.ini ansible/playbooks/site.yml -v
```

### 5. Verify Deployment
```bash
# Check web servers
curl http://<ALB_DNS_NAME>/

# Check application tier directly
curl http://<APP_SERVER_IP>:8080/health

# Check application info
curl http://<APP_SERVER_IP>:8080/info
```

## Playbook Details

### Web Tier (web.yml)
- Installs Apache httpd with mod_proxy modules
- Configures load balancing to application tier
- Sets up proxy rules with round-robin balancing
- Enables firewall rules for HTTP/HTTPS
- Creates health check page

### Application Tier (app.yml)
- Installs Python3, Flask, Gunicorn
- Deploys Flask application
- Configures systemd service for auto-start
- Sets up application-specific firewall rules
- Performs health check validation

## Troubleshooting

### SSH Connection Issues
```bash
# Add verbose flag to debug SSH issues
ansible -i ansible/inventory.ini -u ec2-user -v all -m ping
```

### Check Playbook Syntax
```bash
ansible-playbook --syntax-check ansible/playbooks/site.yml
```

### View Task Execution
```bash
# Run with increased verbosity
ansible-playbook -i ansible/inventory.ini ansible/playbooks/site.yml -vvv
```

### Manual Service Management
```bash
# SSH into instance
ssh -i ~/.ssh/terraform.pem ec2-user@<SERVER_IP>

# Check Flask app status
sudo systemctl status flask-app

# Check Apache status
sudo systemctl status httpd

# View Flask app logs
sudo journalctl -u flask-app -f
```

## Security Considerations
- SSH key must be 600 permissions
- Keep SSH key secure and never commit to version control
- Update security groups in Terraform for specific IP ranges
- Consider using Ansible Vault for sensitive data
- Review and update Flask application security headers

## Automation Options

### Run Playbooks from Terraform
Add Ansible provisioner to Terraform after instances are created:
```hcl
provisioner "local-exec" {
  command = "ansible-playbook -i inventory.ini site.yml"
}
```

### Continuous Deployment
Update the playbooks to pull code from version control:
```yaml
- name: Clone application repository
  git:
    repo: https://github.com/your-org/app-repo.git
    dest: "{{ app_dir }}"
    version: main
```

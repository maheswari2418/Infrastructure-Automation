# Quick Start: Ansible Deployment

## One-Line Setup
```bash
# 1. Deploy infrastructure
terraform init && terraform plan && terraform apply

# 2. Get outputs
terraform output

# 3. Update inventory
sed -i 's/<WEB_1>/YOUR_WEB_1_IP/g' ansible/inventory.ini
sed -i 's/<WEB_2>/YOUR_WEB_2_IP/g' ansible/inventory.ini
sed -i 's/<APP_1>/YOUR_APP_1_IP/g' ansible/inventory.ini
sed -i 's/<APP_2>/YOUR_APP_2_IP/g' ansible/inventory.ini

# 4. Deploy with Ansible
ansible-playbook -i ansible/inventory.ini ansible/playbooks/site.yml
```

## Verify Installation
```bash
# Check web tier
curl http://<ALB_DNS>

# Check app tier
curl http://<APP_IP>:8080/health
```

## Key Components

### Web Tier
- Apache httpd with proxy balancing
- Load balances to app tier servers
- Port 80 listener
- Health check available at /

### Application Tier
- Flask micro-framework
- Gunicorn WSGI server
- Listening on port 8080
- Health check at /health
- Info endpoint at /info

### Database Tier
- RDS MySQL Multi-AZ
- Configured via terraform.tfvars
- Accessible only from app tier

## Common Commands
```bash
# List hosts
ansible-inventory -i ansible/inventory.ini --list

# Test connectivity
ansible -i ansible/inventory.ini all -m ping

# Run on specific group
ansible-playbook -i ansible/inventory.ini -l webservers playbooks/web.yml

# Debug mode
ansible-playbook -i ansible/inventory.ini playbooks/site.yml -vvv
```

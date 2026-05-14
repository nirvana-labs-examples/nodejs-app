<div align="center">
  <a href="https://nirvanalabs.io">
    <img src="https://nirvanalabs.io/brand-kit/logo/nirvana-logo-color-black-text.svg" alt="Nirvana Labs" width="320" />
  </a>

  [Sign Up](https://nirvanalabs.io/sign-up) · [Docs](https://docs.nirvanalabs.io) · [API](https://docs.nirvanalabs.io/api) · [Examples](https://github.com/nirvana-labs-examples) · [Terraform](https://registry.terraform.io/providers/nirvana-labs/nirvana/latest) · [TypeScript SDK](https://www.npmjs.com/package/@nirvana-labs/nirvana) · [Go SDK](https://github.com/Nirvana-Labs/nirvana-go) · [CLI](https://github.com/nirvana-labs/nirvana-cli) · [MCP](https://www.npmjs.com/package/@nirvana-labs/nirvana-mcp)
</div>

---

# Node.js Application on Nirvana Labs

Terraform & Ansible example for deploying a Node.js application with PM2 process manager and Nginx reverse proxy.

## Architecture

```
┌─────────────────────────────────────────┐
│              Single VM                  │
│  ┌─────────────┐    ┌────────────────┐  │
│  │   Nginx     │───►│  PM2 Cluster   │  │
│  │   :80/:443  │    │  :3000         │  │
│  │             │    │  (N workers)   │  │
│  └─────────────┘    └────────────────┘  │
└─────────────────────────────────────────┘
```

- **Nginx**: Reverse proxy with load balancing, gzip compression, security headers
- **PM2**: Process manager with cluster mode, auto-restart, log management
- **Node.js 20**: LTS version with sample Express-like application

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) >= 2.9
- [Nirvana Labs API Key](https://console.nirvanalabs.io)
- SSH key pair

## Quick Start (Automated)

### 1. Configure Terraform

```bash
cd terraform

cat > terraform.tfvars << EOF
project_id     = "your-project-id"
ssh_public_key = "ssh-ed25519 AAAA... user@host"
EOF

export NIRVANA_LABS_API_KEY="your-api-key"
```

### 2. Deploy Infrastructure

```bash
terraform init
terraform apply
```

### 3. Generate Ansible Inventory

```bash
cd ..
chmod +x scripts/generate-inventory.sh
./scripts/generate-inventory.sh
```

### 4. Run Ansible Playbook

```bash
cd ansible
ansible-playbook playbook.yml
```

### 5. Access Your Application

Open `http://<PUBLIC_IP>` in your browser.

## Manual Installation

### 1. Install Node.js 20

```bash
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/nodesource.gpg
echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update && sudo apt install -y nodejs
```

### 2. Install PM2

```bash
sudo npm install -g pm2
```

### 3. Create Application

```bash
sudo useradd -r -m -s /bin/bash nodejs
sudo mkdir -p /opt/myapp
sudo chown nodejs:nodejs /opt/myapp

# Create app.js
sudo -u nodejs cat > /opt/myapp/app.js << 'EOF'
const http = require('http');
const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ message: 'Hello from Node.js!', pid: process.pid }));
});

server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
EOF
```

### 4. Start with PM2

```bash
sudo -u nodejs pm2 start /opt/myapp/app.js -i max --name myapp
sudo -u nodejs pm2 save
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u nodejs --hp /home/nodejs
```

### 5. Install and Configure Nginx

```bash
sudo apt install -y nginx

sudo tee /etc/nginx/sites-available/myapp << 'EOF'
upstream myapp_backend {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://myapp_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx
```

## Deploying Your Own Application

Replace the sample app with your own:

```bash
# SSH into the server
ssh ubuntu@<PUBLIC_IP>

# Switch to app user
sudo su - nodejs

# Clone your repo or copy files to /opt/myapp
cd /opt/myapp
git clone https://github.com/your/repo.git .

# Install dependencies
npm install --production

# Restart PM2
pm2 reload all
```

## PM2 Commands

```bash
# As nodejs user
sudo su - nodejs

pm2 status              # View process status
pm2 logs                # View logs
pm2 logs --lines 100    # View last 100 lines
pm2 monit               # Real-time monitoring
pm2 reload all          # Zero-downtime reload
pm2 restart all         # Restart all processes
pm2 stop all            # Stop all processes
pm2 delete all          # Remove all processes
```

## Configuration

### Ansible Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `nodejs_version` | `20` | Node.js major version |
| `app_name` | `myapp` | Application name |
| `app_port` | `3000` | Application port |
| `pm2_instances` | `max` | PM2 instances (max = CPU cores) |

### Terraform Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `instance_type` | `n1-standard-2` | VM instance type |
| `boot_volume_size` | `64` | Boot volume size in GB |

## Ports

| Port | Description |
|------|-------------|
| 22 | SSH access |
| 80 | HTTP (Nginx) |
| 443 | HTTPS (Nginx) |
| 3000 | Node.js app (internal) |

## Cleanup

```bash
cd terraform
terraform destroy
```

## Resources

- [PM2 Documentation](https://pm2.keymetrics.io/docs/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Node.js Documentation](https://nodejs.org/docs/)
- [Nirvana Labs Documentation](https://docs.nirvanalabs.io)

## License

Apache 2.0 — see [LICENSE](LICENSE.md).

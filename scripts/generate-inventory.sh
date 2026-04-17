#!/bin/bash
# Generate Ansible inventory from Terraform output

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"
ANSIBLE_DIR="$SCRIPT_DIR/../ansible"

cd "$TERRAFORM_DIR"

# Get VM IP from terraform output
PUBLIC_IP=$(terraform output -raw vm_public_ip)

# Generate inventory file
INVENTORY_FILE="$ANSIBLE_DIR/inventory.ini"

cat > "$INVENTORY_FILE" << EOF
[nodejs]
nodejs-app ansible_host=${PUBLIC_IP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519
EOF

echo ""
echo "Inventory generated at $INVENTORY_FILE"
echo "Public IP: $PUBLIC_IP"
echo "App URL: http://$PUBLIC_IP"

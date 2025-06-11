#!/bin/bash
# Navigate to terraform directory
cd ../terraform

# Initialize Terraform (downloads required providers)
terraform init

# Apply infrastructure changes automatically
terraform apply -auto-approve

# Display the server IP address
echo "Minecraft Server IP:"
terraform output minecraft_server_ip
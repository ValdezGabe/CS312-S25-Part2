#!/bin/bash
# Navigate to terraform directory  
cd ../terraform

# Destroy all resources automatically
terraform destroy -auto-approve

# Confirmation message
echo "All AWS resources have been destroyed."
# Automated Minecraft Server Deployment

## Background
This project automates the deployment of a Minecraft server on AWS. We use Terraform to create AWS resources and Docker to run Minecraft.

## Requirements

### Tools Tool Install
- Terraform (v1.13.0-dev)
- AWS CLI (2.27.34)
- Git (2.46.2.windows1)

### Project Structure

#### Directory Structure
```
├── README.md
└── minecraft-server/
    ├── terraform/
    │   └── main.tf
    │   └── variables.tf
    │   └── outputs.tf
    │   └── minecraft_bootstrap.sh
    └── scripts/
        └── setup.sh
        └── destroy.sh
```

#### File Contents

`terraform/main.tf`- Defines the AWS infrastructure
- AWS provider configuration
- Security group with rules for Minecraft and SSH
- EC2 instance configuration 
- Installs Docker and runs Minecraft server

```
provider "aws" {
  region = var.aws_region
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "minecraft" {
  name        = "${var.server_name}-sg"
  description = "Minecraft Server Security Group"
  
  ingress {
    description = "Minecraft Port"
    from_port   = var.minecraft_port
    to_port     = var.minecraft_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.server_name}-security-group"
  }
}

resource "aws_instance" "minecraft" {
  ami             = "ami-03c983f9003cb9cd1"  # Ubuntu 22.04 LTS in us-west-2
  instance_type   = var.instance_type
  security_groups = [aws_security_group.minecraft.name]
  
  user_data = templatefile("${path.module}/user_data.sh", {
    minecraft_port = var.minecraft_port
  })
  
  tags = {
    Name = var.server_name
  }
}
```

`terraform/variables.tf`- Defines input variables
- `aws_region`: AWS region 
- `instance_type`: EC2 instance size 
- `minecraft_port`: Server port 
- `server_name`: Name tag for resources

```
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "EC2 instance type for Minecraft server"
  type        = string
  default     = "t2.medium"
}

variable "minecraft_port" {
  description = "Port for Minecraft server"
  type        = number
  default     = 25565
}

variable "server_name" {
  description = "Name tag for the Minecraft server"
  type        = string
  default     = "minecraft-server"
}
```

`terraform/outputs.tf`- Displays info after deployment
- `minecraft_server_ip`: Public IP address of the server
- `instance_id`: ID of the EC2 instance
```
output "minecraft_server_ip" {
  description = "Public IP address of the Minecraft server"
  value       = aws_instance.minecraft.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.minecraft.id
}
```
`minecraft_bootstrap.sh`- EC2 startup script that installs Docker and runs Minecraft:

```
#!/bin/bash
# Update system packages
apt-get update

# Install Docker
apt-get install -y docker.io

# Start and enable Docker service
systemctl start docker
systemctl enable docker

# Run Minecraft server in Docker
docker run -d \
  --name minecraft \
  -p ${minecraft_port}:25565 \
  -e EULA=TRUE \
  -e MEMORY=2G \
  --restart always \
  itzg/minecraft-server:latest
```

`scripts/setup.sh` 

```
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
```

`scripts/destroy.sh`

```
#!/bin/bash
# Navigate to terraform directory  
cd ../terraform

# Destroy all resources automatically
terraform destroy -auto-approve

# Confirmation message
echo "All AWS resources have been destroyed."
```

## Tasks

### Configure Credentials

You have to set up AWS credentials for Terraform to work:

1. Start you AWS Academy Learner Lab.
2. Click on "AWS Details" in the top right corner of your Learner Lab page.

Use the CLI to setup the auth variables:
- You will have to run it three times for the key, secret, and token (Provided in the learner lab credentials) 
```
aws configure set <variable> "<value>"
```
For example:
```
aws configure set aws_access_key_id "REALLY-LONG-AWS-ACCESS-KEY-ID"
```
```
aws configure set aws_secret_access_key "PRETTY-LONG-AWS-SECRET-ACCESS-KEY"
```
```
aws configure set aws_session_token "SUPER-DUPER-LONG-AWS-SESSION-TOKEN"
```

### Pipeline Steps

#### 1. Clone Repository
```
git clone https://github.com/ValdezGabe/CS312-S25-Part2.git
cd CS312-S25-Part2
cd minecraft-server
```

#### 2. Run Terraform
```
cd terraform
terraform init
terraform apply -auto-approve
```

#### 3. Connect To Server
```
# Get IP from terraform output
terraform output minecraft_server_ip

# Verify with nmap
nmap -sV -Pn -p T:25565 <IP_ADDRESS>
```

## Resources

### Terraform
- [Change Infrastructure](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-change)
- [Define Input Variables](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-variables)
- [Query Data with Outputs](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-outputs)
- [Destroy Infrastructure](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-destroy)
### Docker
- [Minecraft Server Docker Image](https://hub.docker.com/r/itzg/minecraft-server)
- [Docker Ubuntu Installation](https://docs.docker.com/engine/install/ubuntu/)

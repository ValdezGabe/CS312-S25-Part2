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
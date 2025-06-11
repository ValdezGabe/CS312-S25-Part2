output "minecraft_server_ip" {
  description = "Public IP address of the Minecraft server"
  value       = aws_instance.minecraft.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.minecraft.id
}
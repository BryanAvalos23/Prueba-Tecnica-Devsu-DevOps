output "subnet_ids" {
  description = "List of subnet IDs created by this module."
  value = {
    for k, subnet in aws_subnet.sbn : k => {
      id   = subnet.id
      tier = var.subnets[k].tier
    }
  }
}

output "subnet_db_ids" {
  description = "List of subnet IDs for database tier."
  value = [
    for k, subnet in aws_subnet.sbn : subnet.id if var.subnets[k].tier == "database"
  ]
}

output "subnet_private_ids" {
  description = "List of subnet IDs for database tier."
  value = [
    for k, subnet in aws_subnet.sbn : subnet.id if var.subnets[k].tier == "private"
  ]
}


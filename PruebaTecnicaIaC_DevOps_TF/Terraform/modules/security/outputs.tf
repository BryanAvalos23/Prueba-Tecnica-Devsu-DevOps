output "security_group_db" {
  description = "ID del grupo de seguridad para la base de datos RDS Aurora."
  value       = aws_security_group.sg-prueba-tecnica-db.id
}

output "security_group_app" {
  description = "ID del grupo de seguridad para la aplicacion web EKS."
  value       = aws_security_group.sg-prueba-tecnica-app.id
}

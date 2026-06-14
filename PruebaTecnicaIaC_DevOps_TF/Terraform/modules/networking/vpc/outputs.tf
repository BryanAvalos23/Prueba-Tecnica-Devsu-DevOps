output "principal" {
  description = "El ID del VPC principal"
  value       = aws_vpc.principal.id
}

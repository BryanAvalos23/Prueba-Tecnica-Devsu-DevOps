output "kms_key" {
  description = "ID de la clave KMS creada para cifrar los recursos."
  value       = aws_kms_key.main.arn
}

variable "cidr_block" {
  description = "El bloque CIDR para la VPC."
  type        = string
}

variable "project-name" {
  description = "El nombre del proyecto para etiquetar los recursos."
  type        = string
}

variable "aws_region" {
  description = "La región de AWS donde se desplegarán los recursos."
  type        = string
}

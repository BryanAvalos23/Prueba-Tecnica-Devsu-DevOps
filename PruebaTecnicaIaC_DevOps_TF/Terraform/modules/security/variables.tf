variable "project-name" {
  description = "El nombre del proyecto para etiquetar los recursos."
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se creará el grupo de seguridad."
  type        = string
}

variable "port_db" {
  description = "Puerto que se permitirá en el grupo de seguridad."
  type        = number
}

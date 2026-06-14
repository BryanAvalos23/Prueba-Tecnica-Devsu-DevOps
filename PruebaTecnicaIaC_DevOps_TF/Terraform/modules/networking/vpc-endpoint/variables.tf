variable "project-name" {
  description = "Nombre del proyecto para nombrar y etiquetar los recursos del endpoint."
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se crearán los endpoints."
  type        = string
}

variable "region" {
  description = "Región de AWS usada para construir los nombres de los servicios VPC Endpoint."
  type        = string
}

variable "subnet_private_ids" {
  description = "Lista de IDs de subredes privadas donde se desplegarán los endpoints de tipo Interface."
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "Lista de IDs de tablas de ruteo privadas asociadas al endpoint Gateway de S3."
  type        = list(string)
}

variable "vpc_cidr" {
  description = "Bloque CIDR de la VPC permitido para acceder al security group de los endpoints."
  type        = string
}

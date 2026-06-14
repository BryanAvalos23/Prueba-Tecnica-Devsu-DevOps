variable "aws_region" {
  description = "La región de AWS donde se desplegarán los recursos."
  type        = string
}

variable "cidr_block" {
  description = "El bloque CIDR para la VPC."
  type        = string
}

variable "project-name" {
  description = "El nombre del proyecto para etiquetar los recursos."
  type        = string
}

variable "subnets" {
  type = map(object({
    name       = string
    cidr_block = string
    tier       = string
    az         = string
  }))
}

variable "cluster_identifier" {
  description = "Identificador único para el clúster de RDS."
  type        = string
}

variable "database_name" {
  description = "Nombre de la base de datos inicial."
  type        = string
}

variable "master_username" {
  description = "Nombre de usuario maestro para la base de datos."
  type        = string
}

variable "master_password" {
  description = "Contraseña para el usuario maestro de la base de datos."
  type        = string
  sensitive   = true
}

variable "engine" {
  description = "Motor de base de datos a utilizar (por ejemplo, aurora-mysql)."
  type        = string
}

variable "availability_zones" {
  description = "Lista de zonas de disponibilidad para el clúster de RDS."
  type        = list(string)
}

variable "engine_version" {
  description = "Versión del motor de base de datos."
  type        = string
}

variable "db_cluster_instance_class" {
  description = "Clase de instancia para los nodos del clúster de RDS."
  type        = string
}
variable "port_db" {
  description = "Puerto en el que la base de datos escuchará."
  type        = number
}

variable "deletion_window_in_days" {
  description = "Cantidad de días antes de eliminar la llave KMS programada para borrado."
  type        = number
}

variable "eks_cluster_role_name" {
  description = "Nombre del rol IAM para el clúster EKS."
  type        = string
}

variable "eks_node_group_role_name" {
  description = "Nombre del rol IAM para el grupo de nodos EKS."
  type        = string
}

# variable "admin_role" {
#   description = "ARN del rol IAM para el acceso administrativo al clúster EKS."
#   type        = string
# }

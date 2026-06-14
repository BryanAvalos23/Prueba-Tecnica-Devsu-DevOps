variable "project-name" {
  description = "El nombre del proyecto para etiquetar los recursos."
  type        = string
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

variable "subnet_ids" {
  type = list(string)
}

variable "port_db" {
  description = "Puerto en el que la base de datos escuchará."
  type        = number
}

variable "security_group_db" {
  description = "ID del grupo de seguridad para la base de datos RDS Aurora."
  type        = string
}

variable "kms_key_id" {
  description = "ID de la clave KMS para cifrar el clúster de RDS."
  type        = string
}

variable "project-name" {
	description = "El nombre del proyecto para etiquetar los recursos."
	type        = string
}

variable "description" {
	description = "Descripción de la llave KMS."
	type        = string
}

variable "deletion_window_in_days" {
	description = "Cantidad de días antes de eliminar la llave KMS programada para borrado."
	type        = number
}

variable "alias_name" {
	description = "Nombre del alias que se asignará a la llave KMS."
	type        = string
}

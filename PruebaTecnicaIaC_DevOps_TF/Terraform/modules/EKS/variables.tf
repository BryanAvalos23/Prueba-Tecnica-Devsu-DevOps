variable "project-name" {
  description = "El nombre del proyecto para etiquetar los recursos."
  type        = string
}

variable "eks_cluster_role_arn" {
  description = "ARN del rol IAM para el clúster EKS."
  type        = string
}

variable "subnet_ids" {
  description = "Lista de IDs de subredes para el clúster EKS."
  type        = list(string)
}

variable "eks_node_group_role_arn" {
  description = "ARN del rol IAM para el grupo de nodos EKS."
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se desplegará el clúster EKS."
  type        = string
}

variable "cidr_block" {
  description = "Bloque CIDR permitido para acceder al security group del clúster EKS."
  type        = string
}

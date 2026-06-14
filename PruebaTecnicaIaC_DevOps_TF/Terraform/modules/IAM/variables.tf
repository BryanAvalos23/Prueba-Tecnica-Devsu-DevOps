variable "eks_cluster_role_name" {
  description = "Nombre del rol IAM para el clúster EKS."
  type        = string
}

variable "eks_node_group_role_name" {
  description = "Nombre del rol IAM para el grupo de nodos EKS."
  type        = string
}

output "eks_cluster_role_arn" {
  description = "ARN del rol IAM para el clúster EKS."
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_group_role_arn" {
  description = "ARN del rol IAM para el grupo de nodos EKS."
  value       = aws_iam_role.eks_node_group_role.arn
}

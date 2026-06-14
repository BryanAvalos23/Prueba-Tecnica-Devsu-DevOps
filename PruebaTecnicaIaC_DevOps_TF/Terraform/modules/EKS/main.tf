resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.project-name}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  ingress {
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project-name}-eks-cluster-sg"
  }
}

resource "aws_eks_cluster" "prueba_tecnica_eks_cluster" {
  name     = "${var.project-name}-eks-cluster"
  role_arn = var.eks_cluster_role_arn

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids = var.subnet_ids

    endpoint_public_access  = true
    endpoint_private_access = true

    public_access_cidrs = ["190.86.75.113/32"]
    security_group_ids  = [aws_security_group.eks_cluster_sg.id]
  }

  tags = {
    Name = "${var.project-name}-eks-cluster"
  }
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.prueba_tecnica_eks_cluster.name
  node_group_name = "${var.project-name}-eks-node-group"
  node_role_arn   = var.eks_node_group_role_arn
  subnet_ids      = var.subnet_ids
  depends_on      = [aws_eks_cluster.prueba_tecnica_eks_cluster]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  tags = {
    Name = "${var.project-name}-eks-node-group"
  }
}

resource "aws_iam_role" "eks_admin_role" {
  name = "${var.project-name}-eks-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/deploy_user_devsu",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_policy" {
  role       = aws_iam_role.eks_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_access_entry" "admin_access" {
  cluster_name  = aws_eks_cluster.prueba_tecnica_eks_cluster.name
  principal_arn = aws_iam_role.eks_admin_role.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.prueba_tecnica_eks_cluster.name
  principal_arn = aws_iam_role.eks_admin_role.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

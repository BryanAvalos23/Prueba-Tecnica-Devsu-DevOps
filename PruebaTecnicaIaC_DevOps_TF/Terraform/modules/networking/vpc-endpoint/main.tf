locals {
  vpc_endpoints = [
    "ec2",
    "ecr.api",
    "ecr.dkr",
    "s3",
    "sts",
    "elasticloadbalancing",
    "autoscaling",
    "logs",
    "secretsmanager"
  ]
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each = toset([
    "com.amazonaws.${var.region}.ec2",
    "com.amazonaws.${var.region}.ecr.api",
    "com.amazonaws.${var.region}.ecr.dkr",
    "com.amazonaws.${var.region}.sts",
    "com.amazonaws.${var.region}.elasticloadbalancing",
    "com.amazonaws.${var.region}.autoscaling",
    "com.amazonaws.${var.region}.logs",
    "com.amazonaws.${var.region}.secretsmanager"
  ])

  vpc_id              = var.vpc_id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_private_ids
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids
}

resource "aws_security_group" "vpc_endpoints_sg" {
  name   = "${var.project-name}-vpc-endpoints-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}

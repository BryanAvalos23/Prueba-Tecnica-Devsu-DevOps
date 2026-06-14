resource "aws_subnet" "sbn" {
  for_each = var.subnets

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  vpc_id            = var.vpc_id

  tags = {
    Name                                                    = "${var.project-name}-${each.value.name}"
    "kubernetes.io/role/elb"                                = each.value.tier == "public" ? "1" : null
    "kubernetes.io/role/internal-elb"                       = each.value.tier == "private" ? "1" : null
    "kubernetes.io/cluster/${var.project-name}-eks-cluster" = "owned"
  }
}

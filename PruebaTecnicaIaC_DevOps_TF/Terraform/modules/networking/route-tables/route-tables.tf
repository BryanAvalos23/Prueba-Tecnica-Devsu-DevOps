resource "aws_route_table" "rt_public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table" "rt_private" {
  vpc_id = var.vpc_id
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table" "rt_db" {
  vpc_id = var.vpc_id
}

resource "aws_route_table_association" "db" {
  for_each = local.db_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.rt_db.id
}

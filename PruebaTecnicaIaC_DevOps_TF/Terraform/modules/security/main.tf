resource "aws_security_group" "sg-prueba-tecnica-db" {
  name        = "${var.project-name}-sg-prueba-tecnica-db"
  description = "Grupo de seguridad para la base de datos RDS Aurora"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project-name}-sg-prueba-tecnica-db"
  }
}

resource "aws_security_group" "sg-prueba-tecnica-app" {
  name        = "${var.project-name}-sg-prueba-tecnica-app"
  description = "Grupo de seguridad para la aplicacion web EKS"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project-name}-sg-prueba-tecnica-app"
  }
}



resource "aws_security_group_rule" "sg-prueba-tecnica-db-ingress" {
  type                     = "ingress"
  from_port                = var.port_db
  to_port                  = var.port_db
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg-prueba-tecnica-db.id
  source_security_group_id = aws_security_group.sg-prueba-tecnica-app.id
}

resource "aws_security_group_rule" "sg-prueba-tecnica-app-egress" {
  type                     = "egress"
  from_port                = var.port_db
  to_port                  = var.port_db
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg-prueba-tecnica-app.id
  source_security_group_id = aws_security_group.sg-prueba-tecnica-db.id
}

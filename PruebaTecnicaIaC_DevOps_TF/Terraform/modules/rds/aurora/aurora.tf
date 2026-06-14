resource "aws_db_subnet_group" "app-web-db-subnet-group" {
  name       = "${var.project-name}-app-web-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project-name}-app-web-db-subnet-group"
  }

}

resource "aws_rds_cluster" "app-web-db" {
  cluster_identifier          = var.cluster_identifier
  database_name               = var.database_name
  master_username             = var.master_username
  manage_master_user_password = true
  engine                      = var.engine
  engine_version              = var.engine_version
  port                        = var.port_db
  db_subnet_group_name        = aws_db_subnet_group.app-web-db-subnet-group.name
  storage_encrypted           = true
  kms_key_id                  = var.kms_key_id
  skip_final_snapshot         = true

  vpc_security_group_ids = [
    var.security_group_db
  ]
  tags = {
    Name = "${var.project-name}-app-web-db"
  }
}

resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${var.cluster_identifier}-instance-write"
  cluster_identifier = aws_rds_cluster.app-web-db.id
  instance_class     = var.db_cluster_instance_class
  engine             = var.engine
  engine_version     = var.engine_version

  tags = {
    Name = "${var.project-name}-instance-write"
  }
}

resource "aws_rds_cluster_instance" "reader" {
  count              = 1
  identifier         = "${var.cluster_identifier}-instance-read-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.app-web-db.id
  instance_class     = var.db_cluster_instance_class
  engine             = var.engine
  engine_version     = var.engine_version

  tags = {
    Name = "${var.project-name}-instance-read-${count.index + 1}"
  }
}

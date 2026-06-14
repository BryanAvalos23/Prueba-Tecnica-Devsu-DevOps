module "vpc" {
  source       = "./modules/networking/vpc"
  project-name = var.project-name
  cidr_block   = var.cidr_block
  aws_region   = var.aws_region
}

module "subnets" {
  source = "./modules/networking/subnets"

  project-name = var.project-name
  vpc_id       = module.vpc.principal

  subnets = var.subnets
}

module "igw" {
  source = "./modules/networking/internet-gateway"

  project-name = var.project-name
  vpc_id       = module.vpc.principal
}

module "route_tables" {
  source = "./modules/networking/route-tables"

  project-name = var.project-name
  vpc_id       = module.vpc.principal
  igw_id       = module.igw.igw_id
  subnets      = module.subnets.subnet_ids
}

module "vpc_endpoints" {
  source = "./modules/networking/vpc-endpoint"

  vpc_id                  = module.vpc.principal
  project-name            = var.project-name
  region                  = var.aws_region
  subnet_private_ids      = module.subnets.subnet_private_ids
  private_route_table_ids = module.route_tables.private_route_table_ids
  vpc_cidr                = var.cidr_block
}

module "security" {
  source = "./modules/security"

  project-name = var.project-name
  vpc_id       = module.vpc.principal
  port_db      = var.port_db
}

module "kms" {
  source = "./modules/kms"

  project-name            = var.project-name
  description             = "Clave KMS para cifrar los recursos de RDS Aurora."
  deletion_window_in_days = var.deletion_window_in_days
  alias_name              = "${var.project-name}-rds-kms-key"
}

module "aurora-postgres" {
  source = "./modules/rds/aurora"

  subnet_ids                = module.subnets.subnet_db_ids
  project-name              = var.project-name
  cluster_identifier        = var.cluster_identifier
  database_name             = var.database_name
  master_username           = var.master_username
  master_password           = var.master_password
  engine                    = var.engine
  availability_zones        = var.availability_zones
  engine_version            = var.engine_version
  db_cluster_instance_class = var.db_cluster_instance_class
  port_db                   = var.port_db
  security_group_db         = module.security.security_group_db
  kms_key_id                = module.kms.kms_key
}

module "ecr" {
  source = "./modules/ECR"

  project-name = var.project-name
}

module "iam" {
  source = "./modules/IAM"

  eks_cluster_role_name    = var.eks_cluster_role_name
  eks_node_group_role_name = var.eks_node_group_role_name
}

module "eks" {
  source = "./modules/EKS"

  project-name            = var.project-name
  eks_cluster_role_arn    = module.iam.eks_cluster_role_arn
  subnet_ids              = module.subnets.subnet_private_ids
  eks_node_group_role_arn = module.iam.eks_node_group_role_arn
  vpc_id                  = module.vpc.principal
  cidr_block              = var.cidr_block
}

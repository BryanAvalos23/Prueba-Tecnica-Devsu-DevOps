aws_region   = "us-east-1"
project-name = "devsu-demo-app"
cidr_block   = "10.0.0.0/16"

subnets = {
  sbn-public-z1 = {
    name       = "sbn-public-z1"
    cidr_block = "10.0.10.0/24"
    tier       = "public"
    az         = "us-east-1a"
  }

  sbn-public-z2 = {
    name       = "sbn-public-z2"
    cidr_block = "10.0.11.0/24"
    tier       = "public"
    az         = "us-east-1b"
  }

  sbn-private-z1 = {
    name       = "sbn-private-z1"
    cidr_block = "10.0.20.0/24"
    tier       = "private"
    az         = "us-east-1a"
  }

  sbn-private-z2 = {
    name       = "sbn-private-z2"
    cidr_block = "10.0.21.0/24"
    tier       = "private"
    az         = "us-east-1b"
  }

  sbn-db-z1 = {
    name       = "sbn-db-z1"
    cidr_block = "10.0.30.0/24"
    tier       = "database"
    az         = "us-east-1a"
  }

  sbn-db-z2 = {
    name       = "sbn-db-z2"
    cidr_block = "10.0.31.0/24"
    tier       = "database"
    az         = "us-east-1b"
  }
}

cluster_identifier        = "web-app-enterprise-db-cluster"
database_name             = "webappdb"
master_username           = "postgresadmin"
master_password           = "soloporquesi"
engine                    = "aurora-postgresql"
availability_zones        = ["us-east-1a", "us-east-1b"]
engine_version            = "16.13"
db_cluster_instance_class = "db.t3.medium"
port_db                   = 15432
deletion_window_in_days   = 7
eks_cluster_role_name     = "prueba-tecnica-eks-cluster-role"
eks_node_group_role_name  = "prueba-tecnica-eks-node-group-role"

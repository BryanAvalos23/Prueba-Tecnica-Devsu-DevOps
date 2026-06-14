locals {
  public_subnets = {
    for k, v in var.subnets :
    k => v
    if v.tier == "public"
  }

  private_subnets = {
    for k, v in var.subnets :
    k => v
    if v.tier == "private"
  }

  db_subnets = {
    for k, v in var.subnets :
    k => v
    if v.tier == "database"
  }
}

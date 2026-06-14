variable "project-name" {
  description = "El nombre del proyecto para etiquetar los recursos."
  type        = string
}

variable "subnets" {
  type = map(object({
    id   = string
    tier = string
  }))
}

variable "vpc_id" {}
variable "igw_id" {}


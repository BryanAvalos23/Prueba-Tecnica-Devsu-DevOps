variable "subnets" {
  type = map(object({
    name       = string
    cidr_block = string
    tier       = string
    az         = string
  }))
}

variable "project-name" {
  description = "El nombre del proyecto para etiquetar los recursos."
  type        = string
}
variable "vpc_id" {}

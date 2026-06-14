resource "aws_ecr_repository" "devsu-prueba-tecnica" {
  name                 = "pruebatecnica/demo-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project-name}-ecr-repository"
  }
}

resource "aws_ecr_lifecycle_policy" "devsu-prueba-tecnica" {
  repository = aws_ecr_repository.devsu-prueba-tecnica.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Retain only the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "sinceImagePushed"
          countNumber = 7
          countUnit   = "days"
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Private ECR Repository
resource "aws_ecr_repository" "main" {
  name                 = "ishiori-k8s-private-ecr"
  image_tag_mutability = "MUTABLE"
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only 2 latest images for k8s-dex-client_* tags"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["k8s-dex-client_"]
          countType     = "imageCountMoreThan"
          countNumber   = 2
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Public ECR Repository
resource "aws_ecrpublic_repository" "public" {
  provider        = aws.us_east_1
  repository_name = "ishiori-k8s-public-ecr"
}
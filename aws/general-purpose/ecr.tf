# Private ECR Repository
resource "aws_ecr_repository" "main" {
  name                 = "ishiori-k8s-private-ecr"
  image_tag_mutability = "MUTABLE"
}
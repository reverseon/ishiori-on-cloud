# Private ECR Repository
resource "aws_ecr_repository" "main" {
  name                 = "ishiori-k8s-dex-client"
  image_tag_mutability = "MUTABLE"
}

# ECR Repository Policy - allows pull access only to the ECR role
resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPullFromECRRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ecr_full_access_role.arn
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}
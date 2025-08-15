# Public ECR Repository
resource "aws_ecrpublic_repository" "main" {
  repository_name = "ishiori-k8s-dex-client"

  tags = {
    Name        = "ishiori-k8s-dex-client"
    Environment = "production"
    Project     = "ishiori"
  }
}
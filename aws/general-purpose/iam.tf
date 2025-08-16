# IAM Role for ECR Access
resource "aws_iam_role" "ecr_pull_role" {
  name = "ECRPullRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::319844025384:role/AWSReservedSSO_AdministratorAccess_*"
        }
      }
    ]
  })

}

# IAM Policy for ECR pull access
resource "aws_iam_policy" "ecr_pull_access_policy" {
  name        = "ECRPullAccessPolicy"
  description = "Policy that provides pull access to private ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "arn:aws:ecr:*:319844025384:repository/*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "ecr_pull_access_attachment" {
  role       = aws_iam_role.ecr_pull_role.name
  policy_arn = aws_iam_policy.ecr_pull_access_policy.arn
}
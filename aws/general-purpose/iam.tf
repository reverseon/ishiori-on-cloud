# IAM Role for ECR Access
resource "aws_iam_role" "ecr_pull_role" {
  name = "ECRPullRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::319844025384:role/aws-reserved/sso.amazonaws.com/ap-northeast-1/AWSReservedSSO_AdministratorAccess_9ac8c34c1d1b91bb"
        }
        Action = "sts:AssumeRole"
      },
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
          "sts:SetSourceIdentity"
        ]
        Effect = "Allow"
        Principal = {
          Service = ["rolesanywhere.amazonaws.com"]
        }
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = [
              "arn:aws:rolesanywhere:ap-northeast-1:319844025384:trust-anchor/7e521ecb-2e18-45aa-95be-00dacc37c7fb"
            ]
          }
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
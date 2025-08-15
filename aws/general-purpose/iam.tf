# IAM Role for ECR Access
resource "aws_iam_role" "ecr_full_access_role" {
  name = "ECRFullAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "ecs-tasks.amazonaws.com",
            "codebuild.amazonaws.com"
          ]
        }
      }
    ]
  })

}

# IAM Policy for full ECR access
resource "aws_iam_policy" "ecr_full_access_policy" {
  name        = "ECRFullAccessPolicy"
  description = "Policy that provides full access to ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:*",
          "ecr-public:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sts:GetServiceBearerToken"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "sts:AWSServiceName" = "codeartifact.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "ecr_full_access_attachment" {
  role       = aws_iam_role.ecr_full_access_role.name
  policy_arn = aws_iam_policy.ecr_full_access_policy.arn
}

# Instance profile for EC2 instances to assume the role
resource "aws_iam_instance_profile" "ecr_instance_profile" {
  name = "ECRInstanceProfile"
  role = aws_iam_role.ecr_full_access_role.name
}
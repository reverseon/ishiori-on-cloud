# Role List that can be assumed with the trust anchor

locals {
  iam_ra_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
              aws_rolesanywhere_trust_anchor.ishiori_ca_trust_anchor.arn
            ]
          }
        }
      }
    ]
  })
}

# 1. AdministratorAccess Role

# resource "aws_iam_role" "administrator_access_role" {
#   provider = aws
#   name     = "AdministratorAccessRole"
#   assume_role_policy = local.iam_ra_assume_role_policy
# }

# resource "aws_iam_role_policy_attachment" "administrator_access_policy_attachment" {
#   provider   = aws
#   role       = aws_iam_role.administrator_access_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }


# 2. Terraform CI S3 Backend Role

resource "aws_iam_role" "terraform_ci_s3_backend_role" {
  provider = aws
  name     = "TerraformCIS3Backend"
  assume_role_policy = local.iam_ra_assume_role_policy
}

resource "aws_iam_role_policy" "terraform_ci_s3_backend_policy" {
  provider = aws
  name     = "TerraformCIS3BackendPolicy"
  role     = aws_iam_role.terraform_ci_s3_backend_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:ListBucket"
        Resource = "arn:aws:s3:::${aws_s3_bucket.terraform_state.id}"
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject"]
        Resource = "arn:aws:s3:::${aws_s3_bucket.terraform_state.id}/*"
      },
      {
        Effect = "Allow"
        Action = "s3:DeleteObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.terraform_state.id}/*.tflock"
      }
    ]
  })
}
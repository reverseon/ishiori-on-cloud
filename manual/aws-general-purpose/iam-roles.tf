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

  github_oidc_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:reverseon/ishiori-on-cloud:*"
          }
        }
      }
    ]
  })

}

# S3 Backend Policy Document
data "aws_iam_policy_document" "terraform_s3_backend" {
  statement {
    effect = "Allow"
    actions = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.terraform_state.id}"]
  }
  
  statement {
    effect = "Allow"
    actions = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.terraform_state.id}/*"]
  }
  
  statement {
    effect = "Allow"
    actions = ["s3:DeleteObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.terraform_state.id}/*.tflock"]
  }
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

# CI Terraform Role for GitHub Actions
resource "aws_iam_role" "ci_terraform_provisions_role" {
  provider = aws
  name     = "CITerraformProvisionsRole"
  assume_role_policy = local.github_oidc_assume_role_policy
}

data "aws_iam_policy_document" "ci_terraform_provisions" {
  statement {
    effect = "Allow"
    actions = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
  
  source_policy_documents = [data.aws_iam_policy_document.terraform_s3_backend.json]
}

resource "aws_iam_role_policy" "ci_terraform_provisions_policy" {
  provider = aws
  name     = "CITerraformProvisionsPolicy"
  role     = aws_iam_role.ci_terraform_provisions_role.name
  policy   = data.aws_iam_policy_document.ci_terraform_provisions.json
}


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
  policy   = data.aws_iam_policy_document.terraform_s3_backend.json
}
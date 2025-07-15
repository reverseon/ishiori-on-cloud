import {
  to = aws_rolesanywhere_trust_anchor.ishiori_ca_trust_anchor
  id = "7e521ecb-2e18-45aa-95be-00dacc37c7fb"
}
resource "aws_rolesanywhere_trust_anchor" "ishiori_ca_trust_anchor" {
  provider = aws
  name     = "ishiori-ca-trust-anchor"
  source {
    source_data {
      x509_certificate_data = file("${path.module}/../../files/ca.intermediate.chain.pub")
    }
    source_type = "CERTIFICATE_BUNDLE"
  }
  enabled = true
}

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

# resource "aws_iam_role" "onpremise_admin_role" {
#   provider = aws
#   name     = "OnPremiseAdmin"
#   assume_role_policy = local.iam_ra_assume_role_policy
# }

# resource "aws_iam_role_policy_attachment" "onpremise_admin_policy" {
#   provider   = aws
#   role       = aws_iam_role.onpremise_admin_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }


# 2. Terraform CI S3 Backend Role

import {
  to = aws_iam_role.terraform_ci_s3_backend_role
  id = "TerraformCIS3Backend"
}

resource "aws_iam_role" "terraform_ci_s3_backend_role" {
  provider = aws
  name     = "TerraformCIS3Backend"
  assume_role_policy = local.iam_ra_assume_role_policy
}

# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "s3:ListBucket",
#       "Resource": "arn:aws:s3:::mybucket"
#     },
#     {
#       "Effect": "Allow",
#       "Action": ["s3:GetObject", "s3:PutObject"],
#       "Resource": "arn:aws:s3:::mybucket/*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": "s3:DeleteObject",
#       "Resource": "arn:aws:s3:::mybucket/*.tflock"
#     }
#   ]
# }

import {
  to = aws_iam_role_policy.terraform_ci_s3_backend_policy
  id = "TerraformCIS3Backend:TerraformCIS3BackendPolicy"
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

# Profile for Allowing to assume the role

import {
  to = aws_rolesanywhere_profile.onpremise_rolesanywhere_profile
  id = "184e4286-bd01-4e54-abd7-f737c3edf350"
}

resource "aws_rolesanywhere_profile" "onpremise_rolesanywhere_profile" {
  provider = aws
  name     = "OnpremiseAllowedRoles"
  role_arns = [
    # aws_iam_role.onpremise_admin_role.arn 
    aws_iam_role.terraform_ci_s3_backend_role.arn
  ]
  enabled = true
}

# Output the trust anchor and profile arns

output "onpremise_rolesanywhere_trust_anchor_arn" {
  value = aws_rolesanywhere_trust_anchor.ishiori_ca_trust_anchor.arn
}

output "onpremise_rolesanywhere_profile_arn" {
  value = aws_rolesanywhere_profile.onpremise_rolesanywhere_profile.arn
}

# output the role arn

output "assumable_by_iam_ra_role_arn" {
  value = aws_rolesanywhere_profile.onpremise_rolesanywhere_profile.role_arns
}
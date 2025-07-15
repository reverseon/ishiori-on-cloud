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

# Profile for Allowing to assume the role

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
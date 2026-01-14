#!/bin/bash

# Terraform State Import Script
# This script imports existing AWS resources into Terraform state
# Run this after losing the terraform.tfstate file

set -e

echo "=== Terraform State Import Script ==="
echo "Make sure you have run: aws sso login --profile ishiori1gp"
echo ""

# Initialize terraform first
echo "Initializing Terraform..."
terraform init

echo ""
echo "Starting imports..."
echo ""

# --- S3 Resources (s3-ci-backend.tf) ---
echo "=== Importing S3 Resources ==="

echo "Importing aws_s3_bucket.terraform_state..."
terraform import aws_s3_bucket.terraform_state ishiori-ci-terraform-state || echo "Failed to import aws_s3_bucket.terraform_state"

echo "Importing aws_s3_bucket_versioning.terraform_state..."
terraform import aws_s3_bucket_versioning.terraform_state ishiori-ci-terraform-state || echo "Failed to import aws_s3_bucket_versioning.terraform_state"

echo "Importing aws_s3_bucket_server_side_encryption_configuration.terraform_state..."
terraform import aws_s3_bucket_server_side_encryption_configuration.terraform_state ishiori-ci-terraform-state || echo "Failed to import aws_s3_bucket_server_side_encryption_configuration.terraform_state"

echo "Importing aws_s3_bucket_public_access_block.terraform_state..."
terraform import aws_s3_bucket_public_access_block.terraform_state ishiori-ci-terraform-state || echo "Failed to import aws_s3_bucket_public_access_block.terraform_state"

# --- IAM OIDC Provider (idp.tf) ---
echo ""
echo "=== Importing IAM OIDC Provider ==="

# Get the OIDC provider ARN - need to construct it from account ID
ACCOUNT_ID=$(aws sts get-caller-identity --profile ishiori1gp --query Account --output text)
echo "AWS Account ID: $ACCOUNT_ID"

echo "Importing aws_iam_openid_connect_provider.github..."
terraform import aws_iam_openid_connect_provider.github "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com" || echo "Failed to import aws_iam_openid_connect_provider.github"

# --- IAM Roles and Policies (iam-roles.tf) ---
echo ""
echo "=== Importing IAM Roles and Policies ==="

echo "Importing aws_iam_role.ci_terraform_provisions_role..."
terraform import aws_iam_role.ci_terraform_provisions_role CITerraformProvisionsRole || echo "Failed to import aws_iam_role.ci_terraform_provisions_role"

echo "Importing aws_iam_role_policy.ci_terraform_provisions_policy..."
terraform import aws_iam_role_policy.ci_terraform_provisions_policy CITerraformProvisionsRole:CITerraformProvisionsPolicy || echo "Failed to import aws_iam_role_policy.ci_terraform_provisions_policy"

echo "Importing aws_iam_role.terraform_ci_s3_backend_role..."
terraform import aws_iam_role.terraform_ci_s3_backend_role TerraformCIS3Backend || echo "Failed to import aws_iam_role.terraform_ci_s3_backend_role"

echo "Importing aws_iam_role_policy.terraform_ci_s3_backend_policy..."
terraform import aws_iam_role_policy.terraform_ci_s3_backend_policy TerraformCIS3Backend:TerraformCIS3BackendPolicy || echo "Failed to import aws_iam_role_policy.terraform_ci_s3_backend_policy"

# --- IAM Roles Anywhere (iamra-trust-anchor.tf) ---
echo ""
echo "=== Importing IAM Roles Anywhere Resources ==="
echo "NOTE: You need to find the Trust Anchor ID and Profile ID from AWS Console or CLI"
echo ""

# Get Trust Anchor ID
echo "Fetching Trust Anchor ID..."
TRUST_ANCHOR_ID=$(aws rolesanywhere list-trust-anchors --profile ishiori1gp --query "trustAnchors[?name=='ishiori-ca-trust-anchor'].trustAnchorId" --output text 2>/dev/null || echo "")

if [ -n "$TRUST_ANCHOR_ID" ] && [ "$TRUST_ANCHOR_ID" != "None" ]; then
    echo "Found Trust Anchor ID: $TRUST_ANCHOR_ID"
    echo "Importing aws_rolesanywhere_trust_anchor.ishiori_ca_trust_anchor..."
    terraform import aws_rolesanywhere_trust_anchor.ishiori_ca_trust_anchor "$TRUST_ANCHOR_ID" || echo "Failed to import aws_rolesanywhere_trust_anchor.ishiori_ca_trust_anchor"
else
    echo "WARNING: Could not find Trust Anchor 'ishiori-ca-trust-anchor'. Manual import required."
    echo "Run: terraform import aws_rolesanywhere_trust_anchor.ishiori_ca_trust_anchor <TRUST_ANCHOR_ID>"
fi

# Get Profile ID
echo "Fetching Roles Anywhere Profile ID..."
PROFILE_ID=$(aws rolesanywhere list-profiles --profile ishiori1gp --query "profiles[?name=='OnpremiseAllowedRoles'].profileId" --output text 2>/dev/null || echo "")

if [ -n "$PROFILE_ID" ] && [ "$PROFILE_ID" != "None" ]; then
    echo "Found Profile ID: $PROFILE_ID"
    echo "Importing aws_rolesanywhere_profile.onpremise_rolesanywhere_profile..."
    terraform import aws_rolesanywhere_profile.onpremise_rolesanywhere_profile "$PROFILE_ID" || echo "Failed to import aws_rolesanywhere_profile.onpremise_rolesanywhere_profile"
else
    echo "WARNING: Could not find Roles Anywhere Profile 'OnpremiseAllowedRoles'. Manual import required."
    echo "Run: terraform import aws_rolesanywhere_profile.onpremise_rolesanywhere_profile <PROFILE_ID>"
fi

echo ""
echo "=== Import Complete ==="
echo ""
echo "Run 'terraform plan' to verify the state matches the actual infrastructure."
echo "If there are differences, you may need to adjust the Terraform configuration or re-import."

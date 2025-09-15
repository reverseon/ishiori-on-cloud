# ishiori-on-cloud

Infrastructure as Code repository for managing Ishiori homelab cloud resources using Terraform.

## Project Structure

```
├── aws/
│   └── general-purpose/     # AWS ECR and IAM resources
├── cloudflare/             # Cloudflare DNS management for ishiori.net
├── manual/
│   └── aws-general-purpose/ # Bootstrap resources requiring manual setup
├── files/                  # Static files and certificates
└── .github/workflows/      # Automated deployment workflows
```

## Components

- **AWS**: ECR repositories for container images and IAM roles for secure access
- **Cloudflare**: DNS zone and record management for `ishiori.net` domain
- **CI/CD**: Automated Terraform deployment via GitHub Actions

## Usage

### Local Development

```bash
# Navigate to target component
cd cloudflare/          # For DNS changes
cd aws/general-purpose/ # For AWS resources

# Standard Terraform workflow
terraform init
terraform plan
terraform apply
```

### Environment Setup

For Cloudflare operations:
```bash
export TF_VAR_cloudflare_api_token="your-token"
```

AWS authentication is handled via OIDC for GitHub Actions.

### Automated Deployment

- **Pull Requests**: Triggers `terraform plan` with results posted as comments
- **Main Branch**: Automatically applies changes after merge
- **Manual**: Use "Workflow Dispatcher" action with folder and check mode parameters

## State Management

Terraform state is stored in S3 with encryption:
- Backend: `ishiori-ci-terraform-state`
- Cloudflare state: `cistate/cloudflare`
- AWS state: `cistate/aws`

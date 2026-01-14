# ACM Certificate for personal website (must be us-east-1 for CloudFront)
resource "aws_acm_certificate" "personal_website" {
  provider                  = aws.us_east_1
  domain_name               = "reon.my.id"
  subject_alternative_names = ["www.reon.my.id"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "personal-website-cert"
  }
}

# Wait for certificate validation
resource "aws_acm_certificate_validation" "personal_website" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.personal_website.arn
}

resource "aws_s3_bucket" "personal_website" {
  bucket = "reverseon-personal-website-bucket"
  tags = {
    Name = "reverseon-personal-website-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "personal_website" {
  bucket = aws_s3_bucket.personal_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "personal_website" {
  bucket = aws_s3_bucket.personal_website.id

  depends_on = [aws_s3_bucket_public_access_block.personal_website]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.personal_website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.personal_website.arn
          }
        }
      }
    ]
  })
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "personal_website" {
  name                              = "personal-website-oac"
  description                       = "OAC for personal website S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "personal_website" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_200"

  origin {
    domain_name              = aws_s3_bucket.personal_website.bucket_regional_domain_name
    origin_id                = "S3-personal-website"
    origin_access_control_id = aws_cloudfront_origin_access_control.personal_website.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-personal-website"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # Custom error responses - show error.html for all HTTP errors
  custom_error_response {
    error_code         = 400
    response_code      = 400
    response_page_path = "/error.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 403
    response_page_path = "/error.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/error.html"
  }

  custom_error_response {
    error_code         = 405
    response_code      = 405
    response_page_path = "/error.html"
  }

  custom_error_response {
    error_code         = 414
    response_code      = 414
    response_page_path = "/error.html"
  }

  custom_error_response {
    error_code         = 416
    response_code      = 416
    response_page_path = "/error.html"
  }

  custom_error_response {
    error_code         = 500
    response_code      = 500
    response_page_path = "/error.html"
  }

  custom_error_response {
    error_code         = 501
    response_code      = 501
    response_page_path = "/error.html"
  }

  custom_error_response {
    error_code         = 502
    response_code      = 502
    response_page_path = "/error.html"
  }

  custom_error_response {
    error_code         = 503
    response_code      = 503
    response_page_path = "/error.html"
  }

  custom_error_response {
    error_code         = 504
    response_code      = 504
    response_page_path = "/error.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Use CloudFront default certificate (Cloudflare will handle your custom domain SSL)
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "personal-website-cloudfront"
  }
}

output "personal_website_cloudfront_domain" {
  value = aws_cloudfront_distribution.personal_website.domain_name
}

output "personal_website_bucket_name" {
  value = aws_s3_bucket.personal_website.id
}

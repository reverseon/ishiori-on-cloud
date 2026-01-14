resource "aws_s3_bucket" "personal_website" {
  bucket = "personal-website-bucket"
  tags = {
    Name = "personal-website-bucket"
  }
}

resource "aws_s3_bucket_website_configuration" "personal_website" {
  bucket = aws_s3_bucket.personal_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "personal_website" {
  bucket = aws_s3_bucket.personal_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "personal_website" {
  bucket = aws_s3_bucket.personal_website.id

  depends_on = [aws_s3_bucket_public_access_block.personal_website]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.personal_website.arn}/*"
      }
    ]
  })
}

output "personal_website_bucket_website_endpoint" {
  value = aws_s3_bucket_website_configuration.personal_website.website_endpoint
}

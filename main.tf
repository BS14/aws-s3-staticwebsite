resource "random_pet" "random" {
    length = 2
}

locals {
    bucket_name = "stackguardian-${random_pet.random.id}"
}

resource "aws_s3_bucket" "s3_bucket" {
    bucket = local.bucket_name
    force_destroy = true
    tags = {
        "Name" = "aws_s3_bucket.s3_bucket.id"
        "Description" = "Demo Bucket for hosting the static website"
        "CreatedBy" = "StackGuardian"
    }
}

resource "aws_s3_bucket_website_configuration" "s3_bucket" {
    bucket = aws_s3_bucket.s3_bucket.bucket
    index_document {
      suffix = "index.html"
    }
    error_document {
      key = "error.html"
    }
}

resource "aws_s3_bucket_cors_configuration" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id  

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }  
}

resource "aws_s3_bucket_acl" "s3_bucket" {
    bucket = aws_s3_bucket.s3_bucket.id
    acl    = "public-read"
    depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.example]
}

resource "aws_iam_user" "s3_bucket" {
  name = local.bucket_name
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "s3_bucket" {
    bucket = aws_s3_bucket.s3_bucket.id
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}/*"
        ]
      },
      {
        Sid = "PublicReadGetObject"
        Principal = "*"
        Action = [
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}/*"
        ]
      },
    ]
  })
  
  depends_on = [aws_s3_bucket_public_access_block.example]
}
resource "null_resource" "upload_to_s3" {
    triggers = {
      always_run = "${timestamp()}"
    }
    provisioner "local-exec" {
        command = "find ${path.module}/content -type f -exec sed -i 's/helloWorld/${var.shop_name}/g' {} + && aws s3 sync ./content/ s3://${aws_s3_bucket.s3_bucket.bucket}/"      
    }
}

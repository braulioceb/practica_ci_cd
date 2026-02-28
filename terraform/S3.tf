terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0, < 7.0.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  version = ">= 6.28.0, < 7.0.0"
}

# ─────────────────────────────────────────────
# S3 Bucket
# ─────────────────────────────────────────────

resource "aws_s3_bucket" "app_bucket" {
  bucket        = var.bucket_name  # debe ser único globalmente
  force_destroy = true

  tags = {
    Project     = "practica-ci-cd"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Bloquear acceso público (buena práctica)
resource "aws_s3_bucket_public_access_block" "app_bucket_block" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─────────────────────────────────────────────
# IAM User para GitHub Actions
# ─────────────────────────────────────────────

resource "aws_iam_user" "github_actions" {
  name = "github-actions-s3-${var.bucket_name}"

  tags = {
    Project   = "practica-ci-cd"
    ManagedBy = "terraform"
  }
}

resource "aws_iam_user_policy" "s3_access" {
  name = "s3-access-policy"
  user = aws_iam_user.github_actions.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.app_bucket.arn
      },
      {
        Sid    = "AllowObjectActions"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.app_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

# ─────────────────────────────────────────────
# Crear estructura de carpetas en S3
# ─────────────────────────────────────────────

# Carpeta: ejemplo.studio/
resource "aws_s3_object" "folder_ejemplo_studio" {
  bucket  = aws_s3_bucket.app_bucket.id
  key     = "ejemplo.studio/"
  content = ""

  depends_on = [aws_s3_bucket.app_bucket]
}

# Carpeta: ejemplo.studio/processed/
resource "aws_s3_object" "folder_processed" {
  bucket  = aws_s3_bucket.app_bucket.id
  key     = "ejemplo.studio/processed/"
  content = ""

  depends_on = [aws_s3_bucket.app_bucket]
}
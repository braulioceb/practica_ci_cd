variable "aws_region" {
  description = "Región de AWS donde se creará el repositorio ECR"
  type        = string
  default     = "us-east-1"
}

variable "ecr_repo_name" {
  description = "Nombre del repositorio en ECR"
  type        = string
  default     = "practica-ci-cd"
}

variable "environment" {
  description = "Ambiente del proyecto (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "Nombre único global para el bucket S3"
  type        = string
  default = "practica-mlops-2026"
  validation {
    condition     = length(var.bucket_name) > 3
    error_message = "El nombre del bucket debe tener más de 3 caracteres."
  }
}
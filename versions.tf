terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }

  # Remote state is intentionally left commented out. For a single-author
  # assessment local state is sufficient; in a team environment this would
  # point at an S3 bucket with DynamoDB state locking.
  #
  # backend "s3" {
  #   bucket         = "tfstate-autoheal-web"
  #   key            = "web-tier/terraform.tfstate"
  #   region         = "ap-southeast-2"
  #   dynamodb_table = "tfstate-locks"
  #   encrypt        = true
  # }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Use the latest version in the 5.x series
    }
  }

  required_version = ">= 1.4.0"  # Ensure compatibility with Terraform versions
}

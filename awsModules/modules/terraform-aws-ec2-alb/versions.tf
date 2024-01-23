terraform {
  required_version = ">= 1.00"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}

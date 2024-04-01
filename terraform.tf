terraform {
  backend "s3" {
    key = "states/supplychain/terraform.tfstate"
  }
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "2.3.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
    }
  }
}

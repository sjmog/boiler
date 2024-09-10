terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.47"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.3"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "hcloud" {
  token = var.hetzner_api_key
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

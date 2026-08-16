terraform {
  required_version = ">= 1.5.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.22.0"
    }
  }
}

provider "cloudflare" {} # Reads CLOUDFLARE_API_TOKEN.

variable "cloudflare_account_id" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}

variable "hostname" {
  type = string
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "demo" {
  account_id = var.cloudflare_account_id
  name       = var.hostname
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "demo" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.demo.id

  depends_on = [cloudflare_zero_trust_access_application.demo]

  config = {
    ingress = [
      {
        hostname = var.hostname
        service  = "http://nginx:80"
      },
      {
        service = "http_status:404" # Required catch-all rule.
      }
    ]
  }
}

resource "cloudflare_dns_record" "demo" {
  zone_id = var.cloudflare_zone_id
  name    = var.hostname
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.demo.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1

  depends_on = [cloudflare_zero_trust_access_application.demo]
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "demo" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.demo.id
}

output "tunnel_token" {
  value     = data.cloudflare_zero_trust_tunnel_cloudflared_token.demo.token
  sensitive = true
}

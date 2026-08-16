variable "enable_access" {
  type    = bool
  default = false
}

variable "access_allowed_emails" {
  type    = list(string)
  default = []
}

data "cloudflare_zero_trust_access_identity_providers" "account" {
  count = var.enable_access ? 1 : 0

  account_id = var.cloudflare_account_id
}

locals {
  otp_identity_provider_id = try([
    for provider in data.cloudflare_zero_trust_access_identity_providers.account[0].result : provider.id
    if provider.type == "onetimepin"
  ][0], "")
}

resource "cloudflare_zero_trust_access_application" "demo" {
  count = var.enable_access ? 1 : 0

  account_id = var.cloudflare_account_id
  name       = var.hostname
  domain     = var.hostname
  type       = "self_hosted"

  allowed_idps              = [local.otp_identity_provider_id]
  auto_redirect_to_identity = true

  policies = [{
    name       = "Allowed emails"
    decision   = "allow"
    precedence = 1
    include = [for email in var.access_allowed_emails : {
      email = { email = email }
    }]
  }]

  lifecycle {
    precondition {
      condition     = local.otp_identity_provider_id != ""
      error_message = "Enable One-time PIN in Cloudflare Zero Trust first."
    }
  }
}

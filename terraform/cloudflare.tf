resource "cloudflare_record" "subdomain" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = var.subdomain
  content = var.web_servers_count > 1 ? hcloud_load_balancer.web_load_balancer[0].ipv4 : hcloud_server.web[0].ipv4_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "subdomain_ipv6" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = var.subdomain
  content = var.web_servers_count > 1 ? hcloud_load_balancer.web_load_balancer[0].ipv6 : hcloud_server.web[0].ipv6_address
  type    = "AAAA"
  proxied = true
}

resource "cloudflare_page_rule" "https" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  target  = var.subdomain == "@" ? "${var.domain_name}/*" : "${var.subdomain}.${var.domain_name}/*"
  actions {
    always_use_https = true
  }
}

resource "cloudflare_zone_settings_override" "domain_settings" {
  zone_id = data.cloudflare_zones.domain.zones[0].id

  settings {
    ssl = "full"
    always_use_https = "on"
    min_tls_version = "1.2"
    automatic_https_rewrites = "on"
  }
}

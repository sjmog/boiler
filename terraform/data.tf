data "cloudinit_config" "cloud_config_web" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/cloudinit/base.yml")
  }

  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/cloudinit/web.yml")
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}

data "cloudinit_config" "cloud_config_accessories" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/cloudinit/base.yml")
  }

  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/cloudinit/accessories.yml")
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}

data "cloudflare_zones" "domain" {
  filter {
    name = var.domain_name
  }
}

data "cloudflare_zone" "domain" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
}

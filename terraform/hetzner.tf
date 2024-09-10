resource "hcloud_ssh_key" "ssh_key_for_hetzner" {
  name       = "ssh-key-for-hetzner"
  public_key = file("~/.ssh/hetzner.pub")
}

resource "hcloud_network" "network" {
  name     = "private-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "network_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/16"
}

resource "hcloud_server" "web" {
  count       = var.web_servers_count
  name        = var.web_servers_count > 1 ? "web-${count.index + 1}" : "web"
  image       = var.operating_system
  server_type = var.server_type
  location    = var.region
  labels = {
    "ssh"  = "yes",
    "http" = "yes"
  }

  user_data = data.cloudinit_config.cloud_config_web.rendered

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.0.${count.index + 2}"
  }

  ssh_keys = [
    hcloud_ssh_key.ssh_key_for_hetzner.id
  ]

  depends_on = [
    hcloud_network.network
  ]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_server" "accessories" {
  count       = var.accessories_count
  name        = var.accessories_count > 1 ? "accessories-${count.index + 1}" : "accessories"
  image       = var.operating_system
  server_type = var.server_type
  location    = var.region
  labels = {
    "http" = "no"
    "ssh"  = "no"
  }

  user_data = data.cloudinit_config.cloud_config_accessories.rendered

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.0.${count.index + var.web_servers_count + 2}"
  }

  ssh_keys = [
    hcloud_ssh_key.ssh_key_for_hetzner.id
  ]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  depends_on = [
    hcloud_network.network
  ]
}

resource "hcloud_load_balancer" "web_load_balancer" {
  count              = var.web_servers_count > 1 ? 1 : 0
  name               = "web-load-balancer"
  load_balancer_type = "lb11"
  location           = var.region
}

resource "hcloud_load_balancer_target" "load_balancer_target" {
  count            = var.web_servers_count > 1 ? 1 : 0
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.web_load_balancer[count.index].id
  label_selector   = "http=yes"
}

resource "hcloud_load_balancer_service" "load_balancer_service" {
  count            = var.web_servers_count > 1 ? 1 : 0
  load_balancer_id = hcloud_load_balancer.web_load_balancer[count.index].id
  protocol         = "http"

  http {
    sticky_sessions = true
  }

  health_check {
    protocol = "http"
    port     = 80
    interval = 10
    timeout  = 5

    http {
      path         = "/up"
      response     = "OK"
      tls          = true
      status_codes = ["200"]
    }
  }
}

resource "hcloud_load_balancer_network" "load_balancer_network" {
  count            = var.web_servers_count > 1 ? 1 : 0
  load_balancer_id = hcloud_load_balancer.web_load_balancer[count.index].id
  network_id       = hcloud_network.network.id
  ip               = "10.0.1.5"

  # **Note**: the depends_on is important when directly attaching the
  # server to a network. Otherwise Terraform will attempt to create
  # server and sub-network in parallel. This may result in the server
  # creation failing randomly.
  depends_on = [
    hcloud_network.network
  ]
}

resource "hcloud_firewall" "block_all_except_ssh" {
  name = "allow-ssh"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  apply_to {
    label_selector = "ssh=yes"
  }
}

resource "hcloud_firewall" "allow_http_https_from_cloudflare" {
  name = "allow-http-https-from-cloudflare"
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "173.245.48.0/20",
      "103.21.244.0/22",
      "103.22.200.0/22",
      "103.31.4.0/22",
      "141.101.64.0/18",
      "108.162.192.0/18",
      "190.93.240.0/20",
      "188.114.96.0/20",
      "197.234.240.0/22",
      "198.41.128.0/17",
      "162.158.0.0/15",
      "104.16.0.0/13",
      "104.24.0.0/14",
      "172.64.0.0/13",
      "131.0.72.0/22",
      "2400:cb00::/32",
      "2606:4700::/32",
      "2803:f800::/32",
      "2405:b500::/32",
      "2405:8100::/32",
      "2a06:98c0::/29",
      "2c0f:f248::/32"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "173.245.48.0/20",
      "103.21.244.0/22",
      "103.22.200.0/22",
      "103.31.4.0/22",
      "141.101.64.0/18",
      "108.162.192.0/18",
      "190.93.240.0/20",
      "188.114.96.0/20",
      "197.234.240.0/22",
      "198.41.128.0/17",
      "162.158.0.0/15",
      "104.16.0.0/13",
      "104.24.0.0/14",
      "172.64.0.0/13",
      "131.0.72.0/22",
      "2400:cb00::/32",
      "2606:4700::/32",
      "2803:f800::/32",
      "2405:b500::/32",
      "2405:8100::/32",
      "2a06:98c0::/29",
      "2c0f:f248::/32"
    ]
  }

  apply_to {
    label_selector = "http=yes"
  }
}

resource "hcloud_firewall" "block_all_inboud_traffic" {
  name = "block-inboud_traffic"
  # Empty rule blocks all inbound traffic
  apply_to {
    label_selector = "ssh=no"
  }
}

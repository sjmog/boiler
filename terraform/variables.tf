variable "hetzner_api_key" {
  description = "The Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

# Hetzner locations
# https://docs.hetzner.com/cloud/general/locations#what-locations-are-there
variable "region" {
  type    = string
  default = "nbg1"
}

# Hetnzer Server types:
# https://docs.hetzner.com/cloud/servers/overview/#shared-vcpu
variable "server_type" {
  type    = string
  default = "cx22"
}

variable "operating_system" {
  type    = string
  default = "ubuntu-24.04"
}

variable "web_servers_count" {
  type    = number
  default = 1
}

variable "accessories_count" {
  type    = number
  default = 1
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Your domain name, e.g. example.com"
  type        = string
}

variable "subdomain" {
  description = "Your subdomain, e.g. www (use @ if you want the apex domain)"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key"
  default     = "boiler-ssh-key"
}

variable "network_name" {
  description = "Name of the network"
  default     = "boiler-network"
}

variable "load_balancer_name" {
  description = "Name of the load balancer"
  default     = "boiler-lb"
}

# Add similar variables for firewalls and other resources

variable "ssh_key_name" {
  description = "Name of the SSH key"
  type        = string
}

variable "network_name" {
  description = "Name of the network"
  type        = string
}

variable "load_balancer_name" {
  description = "Name of the load balancer"
  type        = string
}

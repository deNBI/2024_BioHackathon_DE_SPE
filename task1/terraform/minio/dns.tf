resource "digitalocean_record" "root_dns" {
  domain = var.domain
  type   = "A"
  name   = "@"
  value  = var.denbi_tre_vm_public_ip
}

# Wildcard DNS record
resource "digitalocean_record" "wildcard_dns" {
  domain = var.domain
  type   = "A"
  name   = "*"
  value  = var.denbi_tre_vm_public_ip
}

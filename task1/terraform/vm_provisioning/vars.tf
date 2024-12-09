#################### Variables ####################
variable "name_prefix" {
  type    = string
  default = "<yourname>_denbi_biohackathon"
}

variable "public_key" {
  type = map(any)
  default = {
    name   = "<yourname>_clum_key"
    pubkey = "<your public key>"
  }
}

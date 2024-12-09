#################### Variables ####################
variable "name_prefix" {
  type    = string
  default = "minio_denbi_biohackathon"
}

variable "public_key" {
  type = map(any)
  default = {
    name   = "sanjay_denbi_biohackathon_key"
    pubkey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMXujTv/vcuFxWl/ZI2EBnIieFi3s18iL/tVxabYB0iqZ9TSBaTkzRyn3TivGr2dey7engKEpKb2wctAC2rqNhA= deNBI"
  }
}

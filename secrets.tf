# Consul Gossip Encryption Key
resource "random_id" "consul_gossip_key" {
  byte_length = 32
}

## Consul Bootstrap Token
resource "random_uuid" "consul_bootstrap_token" {}
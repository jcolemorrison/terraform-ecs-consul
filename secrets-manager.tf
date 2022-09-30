# Consul Gossip Key Secret (metadata and top level resource)
resource "aws_secretsmanager_secret" "consul_gossip_key" {
  name_prefix = "${local.project_tag}-gossip-key-"
}

# Consul Gossip Key Secret Value
resource "aws_secretsmanager_secret_version" "consul_gossip_key" {
  secret_id = aws_secretsmanager_secret.consul_gossip_key.id
  secret_string = random_id.consul_gossip_key.b64_std
}

# Consul Bootstrap Token (metadata and top level resource)
resource "aws_secretsmanager_secret" "consul_bootstrap_token" {
  name_prefix = "${local.project_tag}-bootstrap-token-"
}

# Consul Bootstrap Token Secret Value
resource "aws_secretsmanager_secret_version" "consul_bootstrap_token" {
  secret_id = aws_secretsmanager_secret.consul_bootstrap_token.id
  secret_string = random_uuid.consul_bootstrap_token.id
}

# Root CA Certificate Secret (metadata and top level resource)
resource "aws_secretsmanager_secret" "consul_root_ca_cert" {
  name_prefix = "${local.project_tag}-root-ca-cert-"
}

# Root CA Certificate Secret Value
resource "aws_secretsmanager_secret_version" "consul_root_ca_cert" {
  secret_id = aws_secretsmanager_secret.consul_root_ca_cert.id
  secret_string = tls_self_signed_cert.ca_cert.cert_pem
}
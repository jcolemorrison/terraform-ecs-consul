# Fictional Database
data "aws_ssm_parameter" "ubuntu_1804_ami_id" {
  name = "/aws/service/canonical/ubuntu/server/18.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

resource "aws_instance" "database" {
  ami                         = data.aws_ssm_parameter.ubuntu_1804_ami_id.value
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.database.id]
  subnet_id                   = aws_subnet.private[0].id
  key_name                    = var.ec2_key_pair_name

  user_data = base64encode(templatefile("${path.module}/scripts/database.sh", {
  }))

  tags = { "Name" = "${local.project_tag}-database" }

  depends_on = [aws_nat_gateway.nat]
}

# Bastion Server to Access Database
resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.ubuntu_1804_ami_id.value
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  key_name                    = var.ec2_key_pair_name

  tags = { "Name" = "${local.project_tag}-bastion" }
}

# Consul Servers
resource "aws_instance" "consul_server" {
  count = var.consul_server_count

  ami = data.aws_ssm_parameter.ubuntu_1804_ami_id.value
  instance_type = "t3.micro"
  subnet_id = aws_subnet.private[count.index].id
  associate_public_ip_address = false
  key_name = var.ec2_key_pair_name

  vpc_security_group_ids = [aws_security_group.consul_server.id]

  private_ip = local.server_private_ips[count.index]

  iam_instance_profile = aws_iam_instance_profile.consul_instance_profile.name

  tags = { "Name" = "${local.project_tag}-consul-server" }

  user_data = base64encode(templatefile("${path.module}/scripts/server.sh", {
    CA_PUBLIC_KEY = tls_self_signed_cert.ca_cert.cert_pem
    CONSUL_SERVER_PUBLIC_KEY = tls_locally_signed_cert.consul_server_signed_cert.cert_pem
    CONSUL_SERVER_PRIVATE_KEY = tls_private_key.consul_server_key.private_key_pem
    CONSUL_BOOTSTRAP_TOKEN = random_uuid.consul_bootstrap_token.result
    CONSUL_GOSSIP_KEY = random_id.consul_gossip_key.b64_std
    CONSUL_SERVER_COUNT = var.consul_server_count
    CONSUL_SERVER_DATACENTER = var.consul_dc_1
    AUTO_JOIN_TAG = "Name"
    AUTO_JOIN_TAG_VALUE = "${local.project_tag}-consul-server"
    SERVICE_NAME_PREFIX = local.project_tag
  }))

  depends_on = [aws_nat_gateway.nat]
}
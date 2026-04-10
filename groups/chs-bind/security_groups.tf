resource "aws_security_group" "bind" {
  name        = local.common_resource_name
  description = "Security group for the ${var.service_subtype} EC2 instances"
  vpc_id      = data.aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.common_resource_name}"
  })
}

# SSH Access
resource "aws_vpc_security_group_ingress_rule" "bind_ssh_admin" {
  description       = "Allow SSH connectivity for administration"
  security_group_id = aws_security_group.bind.id
  prefix_list_id    = data.aws_ec2_managed_prefix_list.administration_cidr_ranges.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "bind_ssh_shared_services" {
  description       = "Allow SSH connectivity for ansible (via pipelines)"
  security_group_id = aws_security_group.bind.id
  prefix_list_id    = data.aws_ec2_managed_prefix_list.shared_services_cidr_ranges.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

# BIND connectivity with other servers
resource "aws_vpc_security_group_ingress_rule" "bind_dns" {
  for_each = {
    for id, subnet in data.aws_subnet.application :
    id => subnet.cidr_block
  }

  description       = "Allow BIND over the app subnet(s) ${each.key}"
  security_group_id = aws_security_group.bind.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53

 description       = "Allow BIND over the app subnet(s) ${each.key}"
  security_group_id = aws_security_group.bind.id
  cidr_ipv4         = each.value
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
}

# Egress
resource "aws_vpc_security_group_egress_rule" "bind_all_out" {
  description       = "Allow outbound traffic"
  security_group_id = aws_security_group.bind.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

data "aws_ec2_managed_prefix_list" "administration_cidr_ranges" {
  name = "administration-cidr-ranges"
}

data "aws_ec2_managed_prefix_list" "shared_services_cidr_ranges" {
  name = "shared-services-management-cidrs"
}

data "aws_kms_alias" "ebs" {
  name = local.kms_key_alias
}

data "vault_generic_secret" "kms_keys" {
  path = "aws-accounts/${var.aws_account}/kms"
}
data "vault_generic_secret" "kms_key_alias" {
  path = "applications/${var.aws_account}-${var.aws_region}/${var.service}/${var.service_subtype}"
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["vpc-${var.aws_account}"]
  }
}

data "aws_route53_zone" "chs-bind" {
  name   = var.dns_zone
  vpc_id = data.aws_vpc.this.id
}

data "vault_generic_secret" "internal_cidrs" {
  path = "aws-accounts/network/internal_cidr_ranges"
}

data "aws_subnets" "application" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = [var.application_subnet_pattern]
  }
}

data "aws_subnet" "application" {
  for_each = toset(data.aws_subnets.application.ids)
  id       = each.value
}

data "aws_ami" "chs-bind_ami" {
  most_recent = true
  name_regex  = "^chs-bind-ami-\\d.\\d.\\d"

  filter {
    name   = "name"
    values = ["chs-bind-${var.ami_version_pattern}"]
  }

  filter {
    name   = "owner-id"
    values = ["${local.ami_owner_id}"]
  }
}

data "vault_generic_secret" "ami_owner" {
  path = "/applications/${var.aws_account}-${var.aws_region}/${var.service}/${var.service_subtype}"
}

data "vault_generic_secret" "account_ids" {
  path = "aws-accounts/account-ids"
}

data "vault_generic_secret" "security_s3_buckets" {
  path = "aws-accounts/security/s3"
}

data "vault_generic_secret" "security_kms_keys" {
  path = "aws-accounts/security/kms"
}

data "vault_generic_secret" "shared_services_s3" {
  path = "aws-accounts/shared-services/s3"
}

data "vault_generic_secret" "sns_email" {
  path = "/applications/${var.aws_account}-${var.aws_region}/${var.service}/chs-sns/"
}

data "vault_generic_secret" "sns_url" {
  path = "/applications/${var.aws_account}-${var.aws_region}/${var.service}/chs-sns/"
}

data "vault_generic_secret" "chs-bind_ansible_ssh_keys" {
  path = "applications/${var.aws_account}-${var.aws_region}/${var.service}/${var.service_subtype}"
}

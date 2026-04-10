locals {
  application_subnet_ids_by_az = values(zipmap(
    [for s in data.aws_subnet.application : s.availability_zone],
    [for s in data.aws_subnet.application : s.id]
  ))

  common_tags = {
    Environment    = var.environment
    Service        = var.service
    ServiceSubType = var.service_subtype
    Team           = var.team
  }

  common_resource_name = "${var.environment}-${var.service_subtype}"

  security_s3_data            = data.vault_generic_secret.security_s3_buckets.data
  session_manager_bucket_name = local.security_s3_data.session-manager-bucket-name

  shared_services_s3_data = data.vault_generic_secret.shared_services_s3.data
  resources_bucket_name   = local.shared_services_s3_data["resources_bucket_name"]

  security_kms_keys_data  = data.vault_generic_secret.security_kms_keys.data
  ssm_kms_key_id          = local.security_kms_keys_data.session-manager-kms-key-arn
  kms_keys                = data.vault_generic_secret.kms_keys.data
  cloudwatch_logs_kms_key = local.kms_keys.logs

  account_ids_secrets = jsondecode(data.vault_generic_secret.account_ids.data_json)

  kms_key       = data.vault_generic_secret.kms_key_alias.data
  kms_key_alias = local.kms_key["kms_key_alias"]

  sns_email_secret = data.vault_generic_secret.sns_email.data
  #linux_sns_email  = local.sns_email_secret["linux_email"]
  linux_sns_email  = local.sns_email_secret["sns_private_key"]

  bind_ansible_ssh_secrets    = data.vault_generic_secret.bind_ansible_ssh_keys.data
  bind_ansible_ssh_public_key = local.bind_ansible_ssh_secrets["ansible_ssh_public_key"]

  ami_owner    = data.vault_generic_secret.ami_owner.data
  ami_owner_id = local.ami_owner["ami_owner"]

  bind_ansible_public_ssh_key_lookup = nonsensitive(data.vault_generic_secret.chs-bind_ansible_ssh_keys.data)
  bind_ansible_public_ssh_key        = base64decode(local.bind_ansible_public_ssh_key_lookup["ansible_ssh_public_key"])

  disk_info = {
    root_vol = {
      device = "xvda4"
      fstype = var.disk_fs_type
      path   = "/"
    }
  }

}

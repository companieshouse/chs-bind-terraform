build {
  sources = [
    "source.amazon-ebs.builder",
  ]

  provisioner "ansible" {
    groups = [ "${var.configuration_group}" ]
    playbook_file = "${var.playbook_file_path}"
    extra_arguments  = [
      "-e", "aws_region=${var.aws_region}"
    ]
    ansible_env_vars = [
      "ANSIBLE_FORCE_COLOR=1",
      "ANSIBLE_STDOUT_CALLBACK=yaml"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo find /root /home -name authorized_keys -delete",
      "sudo find /root /home -name '.*history' -delete"
    ]
    remote_folder = "/home/ec2-user"
    remote_file = "cleanup.sh"
  }
}

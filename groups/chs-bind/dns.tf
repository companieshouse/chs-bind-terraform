resource "aws_route53_record" "chs-bind" {
  count = var.instance_count

  zone_id = data.aws_route53_zone.chs-bind.zone_id
  name    = "${var.service_subtype}-${count.index + 1}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.bind[count.index].private_ip]
}

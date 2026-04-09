resource "aws_cloudwatch_log_group" "bind" {
  count = var.instance_count

  name              = "/aws/ec2/${local.common_resource_name}-${count.index + 1}"
  retention_in_days = var.default_log_retention_in_days
  kms_key_id        = local.cloudwatch_logs_kms_key

  tags = local.common_tags
}

# EC2

resource "aws_cloudwatch_metric_alarm" "bind_server_cpu95" {
  count = var.monitoring ? var.instance_count : 0

  alarm_name                = "WARNING-bind-${count.index + 1}-CPUUtilization"
  evaluation_periods        = "1"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "95"
  alarm_description         = "This metric monitors ec2 cpu utilization system"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.bind[0].arn]
  ok_actions                = [aws_sns_topic.bind[0].arn]
  dimensions = {
    InstanceId = aws_instance.bind[count.index].id
  }
}

resource "aws_cloudwatch_metric_alarm" "bind_server_StatusCheckFailed" {
  count = var.monitoring ? var.instance_count : 0

  alarm_name                = "CRITICAL-bind-${count.index + 1}-StatusCheckFailed"
  evaluation_periods        = "1"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Maximum"
  threshold                 = "1"
  alarm_description         = "This metric monitors StatusCheckFailed"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.bind[0].arn]
  ok_actions                = [aws_sns_topic.bind[0].arn]
  dimensions = {
    InstanceId = aws_instance.bind[count.index].id
  }
}

resource "aws_cloudwatch_metric_alarm" "bind_server_root_disk_space" {
  count = var.monitoring ? var.instance_count : 0

  alarm_name          = "CRITICAL_bind-${count.index + 1}_%_used_root_vol"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  evaluation_periods  = "1"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "The disk space average precetage is over 80% for the last 10 minutes"
  alarm_actions       = [aws_sns_topic.bind[0].arn]
  ok_actions          = [aws_sns_topic.bind[0].arn]
  dimensions = {
    path         = local.disk_info.root_vol.path
    InstanceId   = aws_instance.bind[count.index].id
    ImageId      = data.aws_ami.chs-bind_ami.id
    InstanceType = var.instance_type
    device       = local.disk_info.root_vol.device
    fstype       = local.disk_info.root_vol.fstype
  }
}


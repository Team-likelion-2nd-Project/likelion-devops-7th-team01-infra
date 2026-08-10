terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.us_east_1]
    }
  }
}
# 결제 알림을 받을 SNS 토픽
resource "aws_sns_topic" "billing_alarm" {
  provider = aws.us_east_1              # Billing 관련 리소스는 us-east-1에서만 생성 가능
  name     = "${var.project_name}-billing-alarm"

  tags = {
    Name    = "${var.project_name}-billing-alarm-topic"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

# SNS 토픽 구독 (이메일로 알림 받기)
resource "aws_sns_topic_subscription" "billing_email" {
  provider  = aws.us_east_1
  topic_arn = aws_sns_topic.billing_alarm.arn
  protocol  = "email"
  endpoint  = var.alert_email             # 알림 받을 이메일 주소
}

# 비용 알림 (CloudWatch Billing Alarm)
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  provider            = aws.us_east_1
  alarm_name          = "${var.project_name}-weekly-billing-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600              # 6시간마다 체크 (Billing 메트릭은 자주 갱신 안 됨)
  statistic           = "Maximum"
  threshold           = var.billing_threshold
 alarm_description   = "주간 예상 비용이 임계값(${var.billing_threshold} USD, 약 8만원)을 초과하면 알림"
  alarm_actions       = [aws_sns_topic.billing_alarm.arn]

  dimensions = {
    Currency = "USD"                       # AWS Billing은 기본적으로 USD 기준
  }

  tags = {
    Name    = "${var.project_name}-billing-alarm"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}
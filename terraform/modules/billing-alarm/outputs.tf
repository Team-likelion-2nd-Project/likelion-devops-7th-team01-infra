output "sns_topic_arn" {
  description = "결제 알림 SNS 토픽 ARN"
  value       = aws_sns_topic.billing_alarm.arn
}

output "alarm_name" {
  description = "생성된 CloudWatch Billing Alarm 이름"
  value       = aws_cloudwatch_metric_alarm.billing_alarm.alarm_name
}
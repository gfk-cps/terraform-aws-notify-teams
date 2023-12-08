output "sns_topic_arn" {
  description = "The ARN of the SNS topic from which messages will be sent to Slack"
  value       = aws_sns_topic.this.arn
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = module.lambda.function_name
}

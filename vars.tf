variable "s3_bucket_arn" {
  description = "Where lambda zip is stored"
  type        = string
}

variable "s3_key" {
  description = "Path to file to deploy as a lamda function"
  type        = string
}

variable "function_name" {
  type        = string
  description = "Name of the lambda function"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to place lambda in"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets to place lambda in"
}

variable "sns_topic_name" {
  type        = string
  description = "Name of the sns topic"
}

variable "webhook_url" {
  type        = string
  description = "Webhook Url from teams chat"
}

variable "notification_begin" {
  description = "Time start when notifications on Slack should be sent out"
  type        = string
  default     = "00:01"
}

variable "notification_end" {
  description = "Time end when notifications on Slack should be sent out"
  type        = string
  default     = "23:59"
}

variable "s3_bucket" {
  description = "Where lambda zip is stored"
  type        = string
}

variable "s3_key" {
  description = "Path to file to deploy as a lamda function"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where API Gateway is restricted to"
  type        = string
}

variable "webhook_url" {
  type        = string
  description = "Webhook Url from teams chat"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "notification_begin" {
  description = "Time start when notifications on Slack should be sent out"
  type        = string
}

variable "notification_end" {
  description = "Time end when notifications on Slack should be sent out"
  type        = string
}


# lambda
module "lambda" {
  source  = "cloudposse/lambda-function/aws"
  version = "0.4.1"

  description                       = "notify-teams Lambda"
  runtime                           = "python3.9"
  handler                           = "org.springframework.cloud.function.adapter.aws.FunctionInvoker::handleRequest"
  s3_key                            = var.s3_key
  s3_bucket                         = var.s3_bucket
  memory_size                       = 512
  timeout                           = 60
  cloudwatch_logs_retention_in_days = 60
  package_type                      = "Zip"
  lambda_environment = {
    variables = {
      PATH = "/usr/local/bin:/usr/bin/:/bin:/opt/bin:/var/task/"
      TEAMS_WEBHOOK_URL = var.webhook_url
    NOTIFICATION_BEGIN = var.notification_begin
    NOTIFICATION_END   = var.notification_end
    }
  }
  custom_iam_policy_arns = [
    aws_iam_policy.notify-teams-policy.arn
  ]
  vpc_config = {
    security_group_ids = [module.sg_lambdas.id]
    subnet_ids         = module.subnets.private_subnet_ids
  }
  tags = merge(
    var.tags,
    { Name = "${var.environment}-notify-teams" }
  )
}

# sns 
resource "aws_sns_topic" "this" {
  name = var.sns_topic_name
  tags = var.tags
}

resource "aws_sns_topic_subscription" "sns_notify_teams" {
  topic_arn     = local.sns_topic_arn
  protocol      = "lambda"
  endpoint      = module.lambda.function_arn
}


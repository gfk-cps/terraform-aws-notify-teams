locals {
  zipfile = "/tmp/notify-teams-${var.environment}.zip"
}

# s3 bucket
resource "aws_s3_object" "object" {
  bucket = split(":", var.s3_bucket_arn)[5]
  key    = var.s3_key
  source = data.archive_file.source.output_path
  etag   = filemd5(data.archive_file.source.output_path)
}

data "archive_file" "source" {
  type        = "zip"
  output_path = local.zipfile
  source_file = "${path.module}/function/notify-teams.py"
}

# lambda
module "lambda" {
  source  = "cloudposse/lambda-function/aws"
  version = "0.5.3"

  description                       = "notify-teams Lambda"
  function_name                     = var.function_name
  runtime                           = "python3.9"
  handler                           = "notify-teams.lambda_handler"
  s3_key                            = aws_s3_object.object.key
  s3_bucket                         = split(":", var.s3_bucket_arn)[5]
  memory_size                       = 512
  timeout                           = 60
  cloudwatch_logs_retention_in_days = 60
  source_code_hash                  = filebase64sha256(local.zipfile)
  package_type                      = "Zip"

  lambda_environment = {
    variables = {
      PATH               = "/usr/local/bin:/usr/bin/:/bin:/opt/bin:/var/task/"
      TEAMS_WEBHOOK_URL  = var.webhook_url
      NOTIFICATION_BEGIN = var.notification_begin
      NOTIFICATION_END   = var.notification_end
    }
  }

  custom_iam_policy_arns = [
    # direct lookup is not possible due to for_each evaluation
    # would be aws_iam_policy.notify-teams-policy.arn normally
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.environment}-notify-teams-policy",
  ]

  vpc_config = {
    security_group_ids = [module.sg.id]
    subnet_ids         = var.subnet_ids
  }

  tags = merge(
    var.tags,
    { Name = "${var.environment}-notify-teams" }
  )

  depends_on = [
    aws_iam_policy.notify-teams-policy
  ]
}

# security group
module "sg" {
  source  = "cloudposse/security-group/aws"
  version = "2.0.0"

  attributes       = ["lambdas"]
  allow_all_egress = true
  vpc_id           = var.vpc_id

  rule_matrix = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      rules = [
        {
          key       = "ssl"
          type      = "ingress"
          from_port = 443
          to_port   = 443
          protocol  = "tcp"
        }
      ]
    }
  ]
}

# sns 
resource "aws_sns_topic" "this" {
  name = var.sns_topic_name
  tags = var.tags
}

resource "aws_sns_topic_subscription" "sns_notify_teams" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "lambda"
  endpoint  = module.lambda.arn
}


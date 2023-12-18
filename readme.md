# terraform-aws-notify-teams

This module creates a SNS topic that forwards Cloudwatch Alarms to Microsoft
Teams

## Usage

``` terraform
module "notify_teams" {
  source = "git::https://github.com/gfk-cps/terraform-aws-notify-teams.git?ref=0.0.4"
 
  name           = "notify-teams"
  function_name  = "${var.environment}-teams"
  sns_topic_name = "${var.environment}-teams"
  environment    = var.environment
 
  webhook_url   = "https://webhook.office...."
  s3_bucket_arn = module.notify_teams_bucket.bucket_arn  # s3 bucket needs to be created externally!
  s3_key        = "notify-teams.zip"
  subnet_ids    = module.subnets.private_subnet_ids
  vpc_id        = module.vpc.vpc_id
}
```

## Usage with cloudposse label

This module supports [cloudposse label](https://github.com/cloudposse/null)
to label resources in terraform+aws


``` terraform
module "notify_teams_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name            = "notify-teams"
  namespace       = "acme"
  environment     = "preprod"
  id_length_limit = 64
  tags            = var.default_tags
}

module "dpd_notify_teams" {
  source = "git::https://github.com/gfk-cps/terraform-aws-notify-teams.git?ref=0.0.4"
 
  context        = module.notify_teams_label.context

  function_name  = "${module.notify_teams_label.name}-myteam"
  sns_topic_name = "${module.notify_teams_label.name}-myteam"
 
  webhook_url   = "https://webhook.office...."
  s3_bucket_arn = module.notify_teams_bucket.bucket_arn
  s3_key        = "notify-teams.zip"
  subnet_ids    = module.subnets.private_subnet_ids
  vpc_id        = module.vpc.vpc_id
}
```

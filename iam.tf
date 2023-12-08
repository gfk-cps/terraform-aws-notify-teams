
# Permissions for Lua Lambda
data "aws_iam_policy_document" "notify-teams-policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:GetObjectVersion",
      "s3:DeleteObjectVersion",
      "s3:PutObjectAcl",
      "s3:GetObjectAcl",
    ]

    resources = concat(
      [
        "${var.s3_bucket}/*",
        var.s3_bucket,
      ]
    )

    effect = "Allow"
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
}

resource "aws_iam_policy" "notify-teams-policy" {
  name        = "${var.environment}-notify-teams-policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.notify-teams-policy.json
}

# IAM roles for ecs resources
resource "aws_iam_role" "ecs-role" {
  name = "${var.deployment_name}-ecs"
  assume_role_policy = data.aws_iam_policy_document.ecs-policy.json
}

resource "aws_iam_policy" "ecs-permissions" {
  name = "${var.deployment_name}-ecs"
  policy = data.aws_iam_policy_document.ecs-permissions.json
}

resource "aws_iam_role_policy_attachment" "ecs-permissions-attachment" {
  policy_arn = aws_iam_policy.ecs-permissions.arn
  role = aws_iam_role.ecs-role.name
}

data "aws_iam_policy_document" "ecs-permissions" {
  statement {
    actions = [
      "iam:GetRole",
      "iam:PassRole",
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs-policy" {
  statement {
      actions = ["sts:AssumeRole"]
      principals {
        identifiers = ["ecs-tasks.amazonaws.com"]
        type = "Service"
      }
  }
}

# IAM roles for cloudwatch events
resource "aws_iam_role" "cloudwatch-role" {
  name = "${var.deployment_name}-cloudwatch"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch-policy.json
}

resource "aws_iam_policy" "cloudwatch-permissions" {
  name = "${var.deployment_name}-cloudwatch"
  policy = data.aws_iam_policy_document.cloudwatch-permissions.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch-permissions-attachment" {
  policy_arn = aws_iam_policy.cloudwatch-permissions.arn
  role = aws_iam_role.cloudwatch-role.name
}

data "aws_iam_policy_document" "cloudwatch-permissions" {
  statement {
    actions = [
      "iam:GetRole",
      "iam:PassRole",
      "ecs:RunTask"
    ]
    effect = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cloudwatch-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["events.amazonaws.com"]
      type = "Service"
    }
  }
}

# IAM user responsible for uploading results to S3
resource "aws_iam_user" "iam-user" {
  name = "${var.deployment_name}-iam"
  path = "/applications/${var.service-name}/${var.environment}"
  tags = {
    Name = "${var.deployment_name}-iam"
    Environment = var.environment
    Service = var.service-name
  }
}

resource "aws_iam_access_key" "iam-user" {
  user = aws_iam_user.iam-user.name
}

resource "aws_iam_user_policy" "iam-user" {
  name = "${var.deployment_name}-iam"
  user = aws_iam_user.iam-user.name
  policy = data.aws_iam_policy_document.iam-user.json
}

data "aws_iam_policy_document" "iam-user" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      var.result_bucket_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListObjectsV2",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:DeleteObject"
    ]
    resources = [
      "${var.result_bucket_arn}/*"
    ]
  }
}
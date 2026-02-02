# DynamoDB Table for storing emails
resource "aws_dynamodb_table" "email-list" {
  name           = "${var.project_name}-email-list-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "email"

  attribute {
    name = "email"
    type = "S"
  }

  tags = local.common_tags
}

# IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM policy for Lambda to access DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "${var.project_name}-lambda-dynamodb-policy-${var.environment}"
  description = "IAM policy for Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = [
          aws_dynamodb_table.email-list.arn,
          "${aws_dynamodb_table.email-list.arn}/index/*"
        ]
      }
    ]
  })

  tags = local.common_tags
}

# Attach the DynamoDB policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# Attach the basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "submit_email_logs" {
  name              = "/aws/lambda/${var.project_name}-submit-email-${var.environment}"
  retention_in_days = 14
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "get_emails_logs" {
  name              = "/aws/lambda/${var.project_name}-get-emails-${var.environment}"
  retention_in_days = 14
  tags              = local.common_tags
}

# IAM policy for Lambda to access S3 event flyers
resource "aws_iam_policy" "lambda_s3_events_policy" {
  name        = "${var.project_name}-lambda-s3-events-policy-${var.environment}"
  description = "IAM policy for Lambda to list and read event flyer images from S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = [aws_s3_bucket.website.arn]
        Condition = {
          StringLike = {
            "s3:prefix" = ["events/*"]
          }
        }
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = ["${aws_s3_bucket.website.arn}/events/*"]
      }
    ]
  })

  tags = local.common_tags
}

# Attach the S3 events policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_s3_events_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_events_policy.arn
}

# CloudWatch Log Group for get-event-flyers Lambda
resource "aws_cloudwatch_log_group" "get_event_flyers_logs" {
  name              = "/aws/lambda/${var.project_name}-get-event-flyers-${var.environment}"
  retention_in_days = 1
  tags              = local.common_tags
}

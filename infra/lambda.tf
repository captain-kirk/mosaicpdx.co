# Archive the Lambda function code
data "archive_file" "submit_email_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/submit-email"
  output_path = "${path.module}/lambda-packages/submit-email.zip"
}

data "archive_file" "get_emails_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/get-emails"
  output_path = "${path.module}/lambda-packages/get-emails.zip"
}

# Lambda function for submitting emails
resource "aws_lambda_function" "submit_email" {
  filename         = data.archive_file.submit_email_zip.output_path
  function_name    = "mosaic-submit-email-${var.environment}"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 30
  source_code_hash = data.archive_file.submit_email_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME   = aws_dynamodb_table.email-list.name
      CORS_ORIGINS = "https://mosaicpdx.co"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_dynamodb_policy_attachment,
    aws_cloudwatch_log_group.submit_email_logs,
  ]

  tags = local.common_tags
}

# Lambda function for getting emails
resource "aws_lambda_function" "get_emails" {
  filename         = data.archive_file.get_emails_zip.output_path
  function_name    = "mosaic-get-emails-${var.environment}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  timeout          = 30
  source_code_hash = data.archive_file.get_emails_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME   = aws_dynamodb_table.email-list.name
      CORS_ORIGINS = "https://mosaicpdx.co"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_dynamodb_policy_attachment,
    aws_cloudwatch_log_group.get_emails_logs,
  ]

  tags = local.common_tags
}

# Lambda permission for API Gateway to invoke submit email function
resource "aws_lambda_permission" "api_gateway_submit_email" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.submit_email.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# Lambda permission for API Gateway to invoke get emails function
resource "aws_lambda_permission" "api_gateway_get_emails" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_emails.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# Archive the get-event-flyers Lambda function code
data "archive_file" "get_event_flyers_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/get-event-flyers"
  output_path = "${path.module}/lambda-packages/get-event-flyers.zip"
}

# Lambda function for getting event flyers from S3
resource "aws_lambda_function" "get_event_flyers" {
  filename         = data.archive_file.get_event_flyers_zip.output_path
  function_name    = "mosaic-get-event-flyers-${var.environment}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  timeout          = 30
  source_code_hash = data.archive_file.get_event_flyers_zip.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME      = aws_s3_bucket.website.bucket
      CLOUDFRONT_DOMAIN = var.domain_name
      CORS_ORIGINS     = "https://mosaicpdx.co"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_s3_events_policy_attachment,
    aws_cloudwatch_log_group.get_event_flyers_logs,
  ]

  tags = local.common_tags
}

# Lambda permission for API Gateway to invoke get event flyers function
resource "aws_lambda_permission" "api_gateway_get_event_flyers" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_event_flyers.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

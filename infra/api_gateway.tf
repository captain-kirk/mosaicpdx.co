locals {
  # This value needs to be wrapped in single quotes for the API Gateway header
  allowed_origins = "'https://mosaicpdx.co'"
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-api-${var.environment}"
  description = "API Gateway for ${var.project_name} email collection"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = local.common_tags
}

# API Gateway Custom Domain
resource "aws_api_gateway_domain_name" "main" {
  domain_name              = "api.${var.domain_name}"
  regional_certificate_arn = aws_acm_certificate.main.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = local.common_tags
}

# API Gateway Base Path Mapping
resource "aws_api_gateway_base_path_mapping" "main" {
  domain_name = aws_api_gateway_domain_name.main.domain_name
  api_id      = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
}

# API Gateway Resource for submit-email
resource "aws_api_gateway_resource" "submit_email" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "submit-email"
}

# API Gateway Method for POST /submit-email
resource "aws_api_gateway_method" "submit_email_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.submit_email.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Method for OPTIONS /submit-email (CORS Preflight)
resource "aws_api_gateway_method" "submit_email_options" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.submit_email.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# API Gateway Method Response for OPTIONS /submit-email
resource "aws_api_gateway_method_response" "submit_email_options_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.submit_email.id
  http_method = aws_api_gateway_method.submit_email_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# API Gateway Integration for OPTIONS /submit-email (CORS Preflight)
resource "aws_api_gateway_integration" "submit_email_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.submit_email.id
  http_method = aws_api_gateway_method.submit_email_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# API Gateway Integration Response for OPTIONS /submit-email
resource "aws_api_gateway_integration_response" "submit_email_options_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.submit_email.id
  http_method = aws_api_gateway_method.submit_email_options.http_method
  status_code = aws_api_gateway_method_response.submit_email_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = local.allowed_origins
  }

  depends_on = [aws_api_gateway_method.submit_email_options, aws_api_gateway_integration.submit_email_options]
}

# API Gateway Resource for emails
resource "aws_api_gateway_resource" "emails" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "emails"
}

# API Gateway Method for GET /emails
resource "aws_api_gateway_method" "emails_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.emails.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Integration for submit-email POST
resource "aws_api_gateway_integration" "submit_email_post" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.submit_email.id
  http_method = aws_api_gateway_method.submit_email_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.submit_email.invoke_arn
}

# API Gateway Integration for emails GET
resource "aws_api_gateway_integration" "emails_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.emails.id
  http_method = aws_api_gateway_method.emails_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_emails.invoke_arn
}

# API Gateway Method Response for submit-email POST
resource "aws_api_gateway_method_response" "submit_email_post_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.submit_email.id
  http_method = aws_api_gateway_method.submit_email_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# API Gateway Method Response for emails GET
resource "aws_api_gateway_method_response" "emails_get_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.emails.id
  http_method = aws_api_gateway_method.emails_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# API Gateway Resource for event-flyers
resource "aws_api_gateway_resource" "event_flyers" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "event-flyers"
}

# API Gateway Method for GET /event-flyers
resource "aws_api_gateway_method" "event_flyers_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.event_flyers.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Method for OPTIONS /event-flyers (CORS Preflight)
resource "aws_api_gateway_method" "event_flyers_options" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.event_flyers.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# API Gateway Method Response for OPTIONS /event-flyers
resource "aws_api_gateway_method_response" "event_flyers_options_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.event_flyers.id
  http_method = aws_api_gateway_method.event_flyers_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# API Gateway Integration for OPTIONS /event-flyers (CORS Preflight)
resource "aws_api_gateway_integration" "event_flyers_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.event_flyers.id
  http_method = aws_api_gateway_method.event_flyers_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# API Gateway Integration Response for OPTIONS /event-flyers
resource "aws_api_gateway_integration_response" "event_flyers_options_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.event_flyers.id
  http_method = aws_api_gateway_method.event_flyers_options.http_method
  status_code = aws_api_gateway_method_response.event_flyers_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = local.allowed_origins
  }

  depends_on = [aws_api_gateway_method.event_flyers_options, aws_api_gateway_integration.event_flyers_options]
}

# API Gateway Integration for event-flyers GET
resource "aws_api_gateway_integration" "event_flyers_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.event_flyers.id
  http_method = aws_api_gateway_method.event_flyers_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_event_flyers.invoke_arn
}

# API Gateway Method Response for event-flyers GET
resource "aws_api_gateway_method_response" "event_flyers_get_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.event_flyers.id
  http_method = aws_api_gateway_method.event_flyers_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment

  tags = local.common_tags
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    # Redeploy whenever the API configuration changes
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.submit_email.id,
      aws_api_gateway_method.submit_email_post.id,
      aws_api_gateway_integration.submit_email_post.id,
      aws_api_gateway_method.submit_email_options.id,
      aws_api_gateway_integration.submit_email_options.id,
      aws_api_gateway_resource.emails.id,
      aws_api_gateway_method.emails_get.id,
      aws_api_gateway_integration.emails_get.id,
      aws_api_gateway_resource.event_flyers.id,
      aws_api_gateway_method.event_flyers_get.id,
      aws_api_gateway_integration.event_flyers_get.id,
      aws_api_gateway_method.event_flyers_options.id,
      aws_api_gateway_integration.event_flyers_options.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}


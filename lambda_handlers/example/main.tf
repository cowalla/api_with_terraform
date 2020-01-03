# Variables
variable "deploy_region" {}  // e.g. us-west-2

variable "accountId" {}  // 12-digit number

provider "aws" {  // MAY NEED TO CONFIGURE TO YOUR MACHINE
  region = "${var.deploy_region}"
  profile = "MY-PROFILE"
}

# API Gateway
resource "aws_api_gateway_rest_api" "example_api" {
  name = "example_api"
  description = "an example deployment of a lambda"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "example_resource" {
  path_part   = "example_path"
  parent_id   = "${aws_api_gateway_rest_api.example_api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
}

resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id   = "${aws_api_gateway_resource.example_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "example_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id             = "${aws_api_gateway_resource.example_resource.id}"
  http_method             = "${aws_api_gateway_method.example_method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda.invoke_arn}"
}

resource "aws_api_gateway_deployment" "example_deployment" {
  depends_on  = ["aws_api_gateway_integration.example_integration"]
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  stage_name  = "dev"
}

resource "aws_api_gateway_stage" "example_stage" {
  stage_name    = "example_stage"
  rest_api_id   = "${aws_api_gateway_rest_api.example_api.id}"
  deployment_id = "${aws_api_gateway_deployment.example_deployment.id}"
}

resource "aws_api_gateway_method_settings" "example_settings" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  stage_name  = "${aws_api_gateway_stage.example_stage.stage_name}"
  method_path = "${aws_api_gateway_resource.example_resource.path_part}/${aws_api_gateway_method.example_method.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/laexample/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.deploy_region}:${var.accountId}:${aws_api_gateway_rest_api.example_api.id}/*/${aws_api_gateway_method.example_method.http_method}${aws_api_gateway_resource.example_resource.path}"
}

resource "aws_lambda_function" "lambda" {
  filename      = "build.zip"
  function_name = "example_function"
  role          = "${aws_iam_role.role.arn}"
  handler       = "lambda.example_handler"
  runtime       = "python3.7"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  source_code_hash = "${filebase64sha256("build.zip")}"
}

# IAM
resource "aws_iam_role" "role" {
  name = "example_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}
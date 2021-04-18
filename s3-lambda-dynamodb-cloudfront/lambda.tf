data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/welcome.js"
  output_path = "${path.module}/welcome.js.zip"
}

resource "aws_lambda_function" "get" {
  function_name = "${var.project}-${var.environment}-lambda-customerprofile-read"
  filename      = "${path.module}/welcome.js.zip"
  handler       = "welcome.handler"
  runtime       = "nodejs12.x"
  role          = aws_iam_role.iam_for_lambda.arn
  timeout       = 30
  memory_size   = var.environment == "prod" ? 1024 : 521
  environment {
    variables = {
      region = var.region
      db = "${var.project}-${var.environment}-dynamodb-CustomerProfile"
    }
  }
}

resource "aws_cloudwatch_log_group" "get" {
  name              = "/aws/lambda/${var.project}-${var.environment}-lambda-customerprofile-read"
  retention_in_days = var.environment == "prod" ? 90 : 14
}

resource "aws_lambda_permission" "get-permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}


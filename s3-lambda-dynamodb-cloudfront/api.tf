resource "aws_api_gateway_rest_api" "api" {
  name = "${var.project}-${var.environment}-apigateway"
  # endpoint_configuration {
  #   types = ["REGIONAL"]
  # }
}

resource "aws_api_gateway_resource" "source" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "api"
}


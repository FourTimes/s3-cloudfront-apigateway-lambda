resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.source.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "get" {
  rest_api_id         = aws_api_gateway_rest_api.api.id
  resource_id         = aws_api_gateway_resource.source.id
  http_method         = aws_api_gateway_method.get.http_method
  status_code         = "200"
  response_models     = { 
    "application/json" = "Empty"
    }
  response_parameters = {     
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true 
    }
}
resource "aws_api_gateway_integration" "get" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.source.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  uri                     = aws_lambda_function.get.invoke_arn
  }

resource "aws_api_gateway_integration_response" "get" {
    depends_on = [null_resource.nullResource]

  rest_api_id         = aws_api_gateway_rest_api.api.id
  resource_id         = aws_api_gateway_resource.source.id
  http_method         = aws_api_gateway_method.get.http_method
  status_code         = aws_api_gateway_method_response.get.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET, POST'"
  }
}
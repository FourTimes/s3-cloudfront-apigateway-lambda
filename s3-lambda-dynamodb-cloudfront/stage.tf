resource "null_resource" "nullResource" {
  provisioner "local-exec" {
    command = "sleep 100"
  }
}

resource "aws_api_gateway_deployment" "all" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "stage"
  depends_on  = [null_resource.nullResource]
}

resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
  depends_on          = [ aws_iam_role.cloudwatch ]
}

resource "aws_cloudwatch_log_group" "cloudwatch_log" {
  name              = "${var.project}-${var.environment}-apigateway"
  retention_in_days = var.environment == "prod" ? 90 : 14
  depends_on        = [ aws_api_gateway_rest_api.api ]
}


resource "aws_iam_role" "cloudwatch" {
  name               = "${var.project}-${var.environment}-apigateway-cloudwatch"
  depends_on = [ aws_cloudwatch_log_group.cloudwatch_log ]
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "${var.project}-${var.environment}-apigateway-cloudwatch-policy"
  role = aws_iam_role.cloudwatch.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_api_gateway_stage" "all" {
  stage_name    = var.environment
  depends_on    = [null_resource.nullResource]
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.all.id
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.cloudwatch_log.arn
    format          = <<EOF
{ "requestId":"$context.requestId", "ip": "$context.identity.sourceIp", "caller":"$context.identity.caller", "user":"$context.identity.user","requestTime":"$context.requestTime", "httpMethod":"$context.httpMethod","resourcePath":"$context.resourcePath", "status":"$context.status","protocol":"$context.protocol", "responseLength":"$context.responseLength" }
EOF
}
}


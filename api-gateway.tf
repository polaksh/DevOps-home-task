#####  API Gateway  #####
resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "MyDemoAPI"
  description = "Example API"
}

#####  API Gateway Resources For Lambdas  #####
resource "aws_api_gateway_resource" "docker_1st_resource" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  parent_id   = aws_api_gateway_rest_api.MyDemoAPI.root_resource_id
  path_part   = "first"
}

resource "aws_api_gateway_resource" "docker_2nd_resource" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  parent_id   = aws_api_gateway_rest_api.MyDemoAPI.root_resource_id
  path_part   = "second"
}

#####  API Gateway Methods For Lambdas  #####
resource "aws_api_gateway_method" "docker_1st_method" {
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id   = aws_api_gateway_resource.docker_1st_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "docker_2nd_method" {
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id   = aws_api_gateway_resource.docker_2nd_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

#####  API Gateway Lambdas Integrations  #####
resource "aws_api_gateway_integration" "docker_1st_integration" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id = aws_api_gateway_resource.docker_1st_resource.id
  http_method = aws_api_gateway_method.docker_1st_method.http_method

  integration_http_method = "POST" # Lambda functions are invoked with POST
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.first.invoke_arn
}

resource "aws_api_gateway_integration" "docker_2nd_integration" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id = aws_api_gateway_resource.docker_2nd_resource.id
  http_method = aws_api_gateway_method.docker_2nd_method.http_method

  integration_http_method = "POST" # Lambda functions are invoked with POST
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.second.invoke_arn
}

#####  API Gateway Lambdas Permissions  #####
resource "aws_lambda_permission" "docker_1st_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.first.function_name
  principal     = "apigateway.amazonaws.com"

  # The source ARN specifies that only the specified API Gateway can invoke the function
  source_arn = "${aws_api_gateway_rest_api.MyDemoAPI.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "docker_2nd_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.second.function_name
  principal     = "apigateway.amazonaws.com"

  # The source ARN specifies that only the specified API Gateway can invoke the function
  source_arn = "${aws_api_gateway_rest_api.MyDemoAPI.execution_arn}/*/*/*"
}

resource "aws_api_gateway_deployment" "MyDockerDemoDeployment" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  stage_name  = "test"


  depends_on = [aws_api_gateway_integration.docker_1st_integration, aws_api_gateway_integration.docker_2nd_integration]
}
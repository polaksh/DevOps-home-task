output "api_invoke_url" {
  value = aws_api_gateway_deployment.MyDockerDemoDeployment.invoke_url
}

output "rest_api_id" {
  value = aws_api_gateway_rest_api.MyDemoAPI.id
}

output "first_lambda_url" {
  value = "http://localstack:4566/restapis/${aws_api_gateway_rest_api.MyDemoAPI.id}/${aws_api_gateway_deployment.MyDockerDemoDeployment.stage_name}/_user_request_/${aws_api_gateway_resource.docker_1st_resource.path_part}"
}

output "second_lambda_url" {
  value = "http://localstack:4566/restapis/${aws_api_gateway_rest_api.MyDemoAPI.id}/${aws_api_gateway_deployment.MyDockerDemoDeployment.stage_name}/_user_request_/${aws_api_gateway_resource.docker_2nd_resource.path_part}"
}
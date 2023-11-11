output "api_endpoint" {
  value = aws_apigatewayv2_api.jedi_api.api_endpoint
}

output "api_gateway_execution_arn" {
  value = aws_apigatewayv2_api.jedi_api.execution_arn
}
resource "aws_apigatewayv2_api" "jedi_api" {
  name          = "${var.api_gateway_name}-${var.environment}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "jedi_api_integration" {
  for_each = { for idx, integration in var.integrations : idx => integration}

  api_id           = aws_apigatewayv2_api.jedi_api.id
  integration_type = "AWS_PROXY"

  description        = each.value.integration_description
  integration_method = each.value.integration_method
  integration_uri    = each.value.integration_uri
}

resource "aws_apigatewayv2_route" "jedi_api_route" {
  for_each = { for idx, integration in var.integrations : idx => integration}

  api_id    = aws_apigatewayv2_api.jedi_api.id
  route_key = "${each.value.integration_method} /${each.value.integration_route_key}"
  target    = "integrations/${aws_apigatewayv2_integration.jedi_api_integration[each.key].id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.jedi_api.id
  name        = "default-${lower(var.environment)}"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.main_api_gw.arn

    format = jsonencode(
      {
        requestId               = "$context.requestId"
        sourceIp                = "$context.identity.sourceIp"
        requestTime             = "$context.requestTime"
        protocol                = "$context.protocol"
        httpMethod              = "$context.httpMethod"
        resourcePath            = "$context.resourcePath"
        routeKey                = "$context.routeKey"
        status                  = "$context.status"
        responseLength          = "$context.responseLength"
        integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_cloudwatch_log_group" "main_api_gw" {
  name = "/aws/api-gw/${aws_apigatewayv2_api.jedi_api.name}"

  retention_in_days = 5
}

data "archive_file" "sample" {
  type        = "zip"
  source_dir  = "${path.module}/src/${var.source_dir}"
  output_path = "${path.module}/upload/${var.source_dir}.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = "${var.lambda_function_name}-${var.environment}"
  description   = var.lambda_function_description
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.lambda_handler"

  filename         = data.archive_file.sample.output_path
  source_code_hash = data.archive_file.sample.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = merge(var.environment_variables, { PASSWORD = var.password })
  }

  tracing_config {
    mode = "Active"
  }

  publish = true
}

resource "aws_lambda_permission" "perms" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*/*"
}

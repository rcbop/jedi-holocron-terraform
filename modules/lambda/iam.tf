resource "aws_iam_role" "lambda_role" {
  name = "JediHolocronLambdaRole-${var.source_dir}-${var.environment}"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = var.s3_policy_arn
}

resource "aws_iam_role_policy_attachment" "cmk_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = var.cmk_policy_arn
}
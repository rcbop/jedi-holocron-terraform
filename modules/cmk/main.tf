resource "aws_kms_key" "jedi_cmk" {
  description         = var.cmk_description
  enable_key_rotation = var.enable_key_rotation
}

data "aws_iam_policy_document" "cmk_policy" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:DescribeKey"
    ]

    resources = [
      aws_kms_key.jedi_cmk.arn,
    ]
  }
}

resource "aws_iam_policy" "cmk_policy" {
  name   = "JediHolocronCMKPolicy-${var.environment}"
  policy = data.aws_iam_policy_document.cmk_policy.json
}
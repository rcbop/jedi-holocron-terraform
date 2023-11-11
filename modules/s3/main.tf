resource "aws_s3_bucket" "jedi_manifests_bucket" {
  bucket = "${lower(var.bucket_name)}-${lower(var.environment)}"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.jedi_manifests_bucket.arn}",
      "${aws_s3_bucket.jedi_manifests_bucket.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name   = "JediHolocronS3Policy-${var.environment}"
  policy = data.aws_iam_policy_document.s3_policy.json
}
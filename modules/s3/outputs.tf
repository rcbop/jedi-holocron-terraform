output "bucket_name" {
  value = aws_s3_bucket.jedi_manifests_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.jedi_manifests_bucket.arn
}

output "s3_policy_arn" {
  value = aws_iam_policy.s3_policy.arn
}
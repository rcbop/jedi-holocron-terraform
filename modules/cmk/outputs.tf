output "cmk_arn" {
  value = aws_kms_key.jedi_cmk.arn
}

output "cmk_id" {
  value = aws_kms_key.jedi_cmk.key_id
}

output "cmk_policy_arn" {
  value = aws_iam_policy.cmk_policy.arn
}
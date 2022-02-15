#output "role-arn" {
#  value       = aws_iam_role.iam_for_kinesis.arn
#  description = "ARN from IAM Role"
#}

output "role-kinesis-analytics-arn" {
  value       = aws_iam_role.iam_for_kinesis.arn
  description = "ARN from IAM Role"
}
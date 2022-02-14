output "arn" {
  description = "kinesis analytics arn"
  value       = aws_kinesis_stream.credit_kinesis_stream.arn
}

output "name" {
  description = "kinesis analytics resource name"
  value       = aws_kinesis_stream.credit_kinesis_stream.name
}
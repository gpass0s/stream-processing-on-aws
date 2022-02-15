output "arn"{
  description = "kinesis analytics for real time credit analysis arn"
  value       = aws_kinesis_analytics_application.kda_application.arn
}

output "id" {
  description = "kinesis analytics for real time credit analysis ID"
  value       = aws_kinesis_analytics_application.kda_application.id
}
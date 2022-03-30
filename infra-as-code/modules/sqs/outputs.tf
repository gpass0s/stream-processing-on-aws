output "arn" {
  value = aws_sqs_queue.queue.arn
}

output "url" {
  value = aws_sqs_queue.queue.url
}
output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.hello.function_name
}

output "lambda_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.hello.arn
}
variable "aws_region" {
  description = "AWS region to deploy Lambda"
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "resil-hello-lambda"
}
# Project 6: Lambda Serverless Function

## Overview
Deployed a Python serverless function on AWS Lambda using Terraform.
Tested via AWS CLI with a live JSON invocation.

## Goals
- Write a Python Lambda handler
- Create an IAM execution role with least-privilege policy
- Deploy infrastructure via Terraform
- Invoke and verify the function via AWS CLI

## Tools Used
- AWS Lambda
- AWS IAM
- Python 3.12
- Terraform
- AWS CLI

## Infrastructure
- Lambda function: `resil-hello-lambda`
- IAM role: `resil-lambda-exec-role`
- Policy: `AWSLambdaBasicExecutionRole`
- Runtime: Python 3.12
- Region: us-east-1

## How to Deploy
```bash
zip lambda.zip handler.py
terraform init
terraform apply
```

## How to Test
```bash
aws lambda invoke \
  --function-name resil-hello-lambda \
  --payload '{"name": "Teng"}' \
  --cli-binary-format raw-in-base64-out \
  response.json && cat response.json
```

## Lessons Learned
- Lambda requires an IAM execution role — it cannot run without one
- `source_code_hash` forces Terraform to redeploy when handler.py changes
- Handler naming must match exactly: `filename.functionname`
- API Gateway (Project 7) will expose this function via public HTTP endpoint

## Next Project
Project 7: API Gateway + Lambda — expose this function via a public URL
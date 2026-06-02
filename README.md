# Project 6 -- Lambda Serverless Function

## Overview

In this project, I deployed a Python serverless function on AWS Lambda using Terraform.

This project introduced serverless compute. Instead of launching and managing a full EC2 server, I created a Lambda function that runs only when invoked. The function was packaged locally, uploaded by Terraform, assigned an IAM execution role, and tested through the AWS CLI.

The Lambda function created in this project is named:

```text
resil-hello-lambda
```

This Lambda function later became the backend for Project 7, where it was exposed through API Gateway.

In plain English, Project 6 created a small cloud worker that can run code without needing a server.

House analogy: EC2 is like renting a whole room where a worker sits all day waiting for tasks. Lambda is like calling a worker only when there is a task to do. The worker appears, completes the task, returns a response, and then stops.

---

## Goals

* Create a new standalone AWS project folder and GitHub repo
* Write a Python Lambda function
* Package the function into a deployment zip file
* Create a Lambda execution role using IAM
* Attach permissions required for Lambda to write logs to CloudWatch
* Deploy the Lambda function using Terraform
* Invoke the Lambda function from the AWS CLI
* Save the Lambda response locally as `response.json`
* Confirm the function returns a valid response
* Push all project code to GitHub
* Keep the Lambda function live for Project 7
* Update the live portfolio and roadmap index after completion

---

## Tools & Environment

| Tool            | Version / Setup                        |
| --------------- | -------------------------------------- |
| OS              | Ubuntu 24.04.4 LTS through WSL2        |
| Terraform       | v1.15.3                                |
| AWS CLI         | 2.34.48                                |
| Git             | 2.43.0                                 |
| GitHub CLI      | 2.45.0                                 |
| Editor          | VS Code opened from WSL using `code .` |
| AWS Region      | `us-east-1`                            |
| AWS CLI Profile | `default`                              |
| Runtime         | Python 3.12                            |
| Lambda Function | `resil-hello-lambda`                   |

---

## Architecture

```text
Developer
    |
    | terraform apply
    v
Terraform
    |
    | creates IAM role + Lambda function
    v
AWS Lambda
    |
    | uses IAM execution role
    v
CloudWatch Logs
```

Testing flow:

```text
AWS CLI invoke command
↓
AWS Lambda runs Python handler
↓
Lambda returns response
↓
Response is saved to response.json
↓
cat response.json confirms output
```

More specifically:

```text
aws lambda invoke
↓
resil-hello-lambda
↓
lambda_function.lambda_handler
↓
JSON response
↓
response.json
```

This project is the foundation for serverless APIs. Lambda handles the compute. Project 7 later added API Gateway as the public HTTP entry point.

---

## Infrastructure Built

| Resource                         | Purpose                                                |
| -------------------------------- | ------------------------------------------------------ |
| `aws_iam_role`                   | Creates the Lambda execution role                      |
| `aws_iam_role_policy_attachment` | Attaches AWS managed permission for CloudWatch logging |
| `aws_lambda_function`            | Creates the Python Lambda function                     |
| `archive_file`                   | Packages the Python code into a zip file               |
| `output` values                  | Prints useful Lambda details after deployment          |

The exact resource names may vary slightly depending on the Terraform file, but the infrastructure pattern is:

```text
Python code
↓
ZIP package
↓
IAM execution role
↓
Lambda function
↓
AWS CLI test invoke
```

---

## File Structure

```text
resil-project-06-lambda/
├── .gitignore              # Excludes local Terraform files, state, zip files, and response.json
├── provider.tf             # AWS provider configuration
├── main.tf                 # Lambda, IAM role, policy attachment, package configuration
├── outputs.tf              # Lambda name, ARN, or invoke details
├── lambda_function.py      # Python Lambda handler code
├── README.md               # Project documentation
└── .terraform.lock.hcl     # Terraform provider dependency lock file
```

Local files intentionally ignored by Git:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
*.tfvars
*.pem
lambda.zip
response.json
```

The `.terraform.lock.hcl` file was intentionally committed because it locks provider dependency versions and makes future Terraform runs more consistent.

---

## Step by Step -- What I Did and Why

### Step 1 -- Created the Project 6 folder

Created a new project folder inside the roadmap workspace:

```bash
cd ~/resil-roadmap
mkdir resil-project-06-lambda
cd resil-project-06-lambda
code .
```

This created a dedicated folder for Project 6.

Why this matters: each project has its own folder, Terraform files, Git history, and GitHub repo. This keeps the cloud roadmap clean and makes each project easy to review independently.

House analogy: each project is like a separate room in the same building. Project 6 is the serverless room. It should not be mixed with the S3, EC2, CloudFront, or Route 53 rooms.

---

### Step 2 -- Created `.gitignore` before Terraform init

Created `.gitignore` before running `terraform init`.

The file included:

```gitignore
.terraform/
terraform.tfstate
terraform.tfstate.backup
*.tfvars
*.pem
lambda.zip
response.json
```

Why this matters: Terraform creates local files that should not be pushed to GitHub. The biggest one is `terraform.tfstate`, because it stores information about real AWS resources.

The Lambda deployment package, `lambda.zip`, was also ignored because it is a generated build artifact. The source code belongs in GitHub, but generated package files do not need to be committed.

House analogy: GitHub should show the blueprint and instructions, not the temporary construction trash or private records.

---

### Step 3 -- Initialized Git

Ran:

```bash
git init
```

This turned the Project 6 folder into a Git repository.

Why this matters: Git tracks the project history. Every major project milestone can be committed, reviewed, and pushed to GitHub.

The clean workflow was:

```text
Create files
↓
Check files
↓
Stage files
↓
Commit files
↓
Push to GitHub
```

---

### Step 4 -- Created `provider.tf`

Created the Terraform provider configuration:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}
```

What this does:

* Uses the official AWS provider
* Uses the archive provider to create a zip package
* Deploys resources into `us-east-1`
* Uses the AWS CLI profile named `default`

Why this matters: Terraform needs to know which cloud provider to use, which region to deploy into, and which credentials to use.

The archive provider is important because Lambda needs code to be uploaded as a zip package.

---

### Step 5 -- Wrote the Python Lambda function

Created a Python file named:

```text
lambda_function.py
```

The function followed this basic structure:

```python
import json

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Hello from RESIL Lambda!"
        })
    }
```

What this does:

```python
import json
```

Loads Python's built-in JSON library.

```python
def lambda_handler(event, context):
```

Defines the function Lambda runs when invoked.

`event` contains the input sent to Lambda.

`context` contains runtime information from AWS, such as request ID and function metadata.

```python
return {
    "statusCode": 200,
    "body": json.dumps({
        "message": "Hello from RESIL Lambda!"
    })
}
```

Returns a basic response.

Why this matters: Lambda needs a handler function. The handler is the entry point AWS calls when the function runs.

House analogy: the handler is the worker's front desk. When a task arrives, AWS sends it to that desk first.

---

### Step 6 -- Packaged the Lambda code

Used Terraform's archive provider to turn the Python file into a zip package.

The Terraform pattern looked like this:

```hcl
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}
```

What this does:

```hcl
type = "zip"
```

Tells Terraform to create a zip file.

```hcl
source_file = "${path.module}/lambda_function.py"
```

Uses the local Python file as the source.

```hcl
output_path = "${path.module}/lambda.zip"
```

Creates the zip package in the project folder.

Why this matters: AWS Lambda expects uploaded deployment code as a zip file when using this deployment method. Terraform packages the code automatically so I do not have to manually zip files each time.

The generated `lambda.zip` file is ignored by Git because it is a build artifact.

---

### Step 7 -- Created the Lambda execution role

Created an IAM role for Lambda.

The Terraform pattern looked like this:

```hcl
resource "aws_iam_role" "lambda_role" {
  name = "resil-hello-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
```

What this does:

```hcl
resource "aws_iam_role" "lambda_role"
```

Creates an IAM role.

```hcl
name = "resil-hello-lambda-role"
```

Names the role.

```hcl
assume_role_policy
```

Defines who is allowed to use this role.

```hcl
Service = "lambda.amazonaws.com"
```

Allows the Lambda service to assume this role.

Why this matters: Lambda needs an execution role before it can run. The execution role is the identity Lambda uses when it performs actions in AWS.

House analogy: the execution role is the worker's badge. Without the badge, the worker is not allowed to enter AWS services or write logs.

---

### Step 8 -- Attached CloudWatch logging permissions

Attached the AWS managed policy for basic Lambda execution:

```hcl
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
```

What this does:

```hcl
role = aws_iam_role.lambda_role.name
```

Attaches the policy to the Lambda execution role.

```hcl
policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
```

Uses the AWS managed policy that allows Lambda to write logs to CloudWatch.

Why this matters: without this policy, the Lambda function may still run, but it would not be able to write logs properly. Logs are critical for troubleshooting.

Cloud engineering takeaway: if something fails in the cloud, logs are usually the first place to look.

---

### Step 9 -- Created the Lambda function

Created the Lambda function with Terraform.

The Terraform pattern looked like this:

```hcl
resource "aws_lambda_function" "hello_lambda" {
  function_name = "resil-hello-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}
```

What this does:

```hcl
function_name = "resil-hello-lambda"
```

Names the Lambda function.

```hcl
role = aws_iam_role.lambda_role.arn
```

Gives Lambda the IAM execution role.

```hcl
handler = "lambda_function.lambda_handler"
```

Tells AWS which Python file and function to run.

This means:

```text
lambda_function.py file
↓
lambda_handler function
```

```hcl
runtime = "python3.12"
```

Uses Python 3.12 as the Lambda runtime.

```hcl
filename = data.archive_file.lambda_zip.output_path
```

Uploads the zip package created by the archive provider.

```hcl
source_code_hash = data.archive_file.lambda_zip.output_base64sha256
```

Tells Terraform when the source code changes.

Why this matters: without `source_code_hash`, Terraform may not always detect that the Lambda package changed. This value helps Terraform know when the function code needs to be updated.

---

### Step 10 -- Created `outputs.tf`

Created outputs so Terraform would print useful information after deployment.

Example outputs:

```hcl
output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.hello_lambda.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.hello_lambda.arn
}
```

Why this matters: outputs make it easier to retrieve important resource details without searching through the AWS Console.

For Project 6, useful outputs included the Lambda function name and ARN.

---

### Step 11 -- Ran Terraform formatting, init, and validation

Ran:

```bash
terraform fmt
terraform init
terraform validate
```

What each command does:

```bash
terraform fmt
```

Formats Terraform files.

```bash
terraform init
```

Downloads the AWS and archive providers.

```bash
terraform validate
```

Checks whether the Terraform configuration is valid.

Why this matters: this catches syntax and configuration issues before touching AWS.

This is the professional workflow:

```text
Write code
↓
Format code
↓
Initialize providers
↓
Validate code
↓
Plan changes
↓
Apply changes
```

---

### Step 12 -- Ran `terraform plan`

Ran:

```bash
terraform plan
```

The expected plan was to create resources similar to:

```text
aws_iam_role
aws_iam_role_policy_attachment
aws_lambda_function
archive_file
```

The expected summary was similar to:

```text
Plan: resources to add, 0 to change, 0 to destroy
```

Why this matters: `terraform plan` previews what Terraform will do before it makes changes in AWS.

This is the safety checkpoint. Before creating cloud resources, I verified that Terraform was only creating the intended Lambda and IAM resources.

---

### Step 13 -- Ran `terraform apply`

Ran:

```bash
terraform apply
```

Then confirmed:

```text
yes
```

Terraform created the Lambda function and supporting IAM role.

Why this matters: this was the actual deployment step. After this completed, the Python function existed in AWS Lambda.

The build path was:

```text
lambda_function.py
↓
lambda.zip
↓
Terraform upload
↓
AWS Lambda function
```

---

### Step 14 -- Invoked the Lambda function with AWS CLI

Ran an AWS CLI test command similar to:

```bash
aws lambda invoke \
  --function-name resil-hello-lambda \
  --payload '{}' \
  response.json
```

Depending on AWS CLI version and payload formatting, the command may require:

```bash
aws lambda invoke \
  --function-name resil-hello-lambda \
  --cli-binary-format raw-in-base64-out \
  --payload '{}' \
  response.json
```

What this does:

```bash
aws lambda invoke
```

Calls the Lambda function directly.

```bash
--function-name resil-hello-lambda
```

Specifies which Lambda function to invoke.

```bash
--payload '{}'
```

Sends an empty JSON event to the function.

```bash
response.json
```

Saves the function response to a local file.

Why this matters: this proved the Lambda function worked before connecting it to any API Gateway or public endpoint.

---

### Step 15 -- Checked the response file

Ran:

```bash
cat response.json
```

This displayed the Lambda response.

The expected result was a JSON response showing that the function ran successfully.

Why this matters: this was the end-to-end test for Project 6.

The test proved:

```text
AWS CLI could invoke Lambda
↓
Lambda could run Python code
↓
Lambda could return a response
↓
The response could be saved locally
```

---

### Step 16 -- Checked Git status

Ran:

```bash
git status
```

Confirmed Git saw the correct project files:

```text
.gitignore
.terraform.lock.hcl
README.md
provider.tf
main.tf
outputs.tf
lambda_function.py
```

Confirmed Git did not include ignored local files:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
lambda.zip
response.json
```

Why this matters: this was the safety check before committing. It confirmed that GitHub would receive source files and documentation, not local state or generated test files.

---

### Step 17 -- Committed the project

Ran:

```bash
git add .
git commit -m "Add Lambda serverless function project"
```

What this does:

```bash
git add .
```

Stages all allowed files.

```bash
git commit -m "Add Lambda serverless function project"
```

Creates a Git checkpoint.

Why this matters: this saved the working Project 6 code into Git history.

---

### Step 18 -- Created the GitHub repo and pushed

Ran:

```bash
gh repo create resil-project-06-lambda --public --source=. --remote=origin
git branch -M main
git push --set-upstream origin main
```

This created the public GitHub repo:

```text
https://github.com/TGLEE4/resil-project-06-lambda
```

Why this matters: the project became part of the public cloud portfolio.

---

### Step 19 -- Kept the Lambda function live for Project 7

Unlike most previous project resources, this Lambda function was intentionally kept live.

Why this matters: Project 7 needed an existing Lambda function to expose through API Gateway.

Project 6 created:

```text
resil-hello-lambda
```

Project 7 used:

```hcl
data "aws_lambda_function" "hello" {
  function_name = "resil-hello-lambda"
}
```

That means Project 7 depended on the Lambda function from Project 6.

Cloud engineering takeaway: not every resource should be destroyed immediately if it is needed by the next project. However, this should be intentional and documented.

---

### Step 20 -- Updated the portfolio and roadmap index

After Project 6 was complete, the portfolio site was updated to include the Lambda Serverless Function project card.

The project card summarized:

```text
Deployed a Python serverless function on AWS Lambda with a least-privilege IAM execution role.
Packaged and deployed via Terraform.
Invoked and verified via AWS CLI with live JSON response.
```

The roadmap index was also updated to mark Project 6 complete and link to the GitHub repo.

Why this matters: the GitHub repo proves the code exists, while the live portfolio makes the project easy for employers to find.

---

## Tradeoff 1 -- Lambda vs EC2

### What this means

There are multiple ways to run code in AWS.

Two common options are:

* EC2
* Lambda

EC2 gives you a virtual server. You manage the operating system, updates, web server, security groups, and uptime.

Lambda runs code without requiring you to manage a server.

### What I chose

I used AWS Lambda.

### Why

This project was focused on serverless compute. The goal was to run a small Python function without provisioning or managing a full Linux server.

Lambda was the better fit because:

* no server needed
* no operating system maintenance
* automatic scaling
* simple function-based deployment
* good foundation for API Gateway

### The tradeoff

Lambda is great for event-driven tasks, APIs, automation, and small units of compute. But it is not always the best fit for long-running workloads, persistent connections, or full web servers.

EC2 gives more control, but also requires more management.

Cloud engineering takeaway: use Lambda when the work can be handled as short-running functions. Use EC2 when you need full server control.

---

## Tradeoff 2 -- AWS Managed IAM Policy vs Custom IAM Policy

### What this means

For Lambda logging, I could either:

* attach the AWS managed `AWSLambdaBasicExecutionRole` policy
* write a custom IAM policy manually

### What I chose

I used the AWS managed policy:

```text
arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

### Why

This project only needed basic Lambda logging to CloudWatch. The AWS managed policy is the standard beginner-friendly option for that purpose.

It allows Lambda to create logs and write log events.

### The tradeoff

AWS managed policies are convenient, but they may include broader permissions than a strict custom policy.

A custom policy gives more control and can follow least privilege more tightly, but it adds complexity.

For this project, the managed policy was acceptable because the goal was to learn Lambda deployment, packaging, IAM execution roles, and testing.

Cloud engineering takeaway: managed policies are useful for learning and common AWS patterns, but production environments often require tighter custom policies.

---

## Tradeoff 3 -- Terraform Packaging vs Manual ZIP

### What this means

Lambda code must be packaged before upload.

I could either:

* manually run a zip command
* let Terraform package the file using the archive provider

### What I chose

I used Terraform packaging with the archive provider.

### Why

This keeps the deployment workflow inside Terraform.

Instead of manually creating `lambda.zip`, Terraform can create it automatically from `lambda_function.py`.

### The tradeoff

Terraform packaging is simple for one-file functions, but larger Lambda projects with dependencies may need a more advanced build process.

For example, if the function used external Python packages, I would need to install dependencies into a build folder before zipping.

Cloud engineering takeaway: Terraform packaging is good for simple Lambda functions. Larger production functions often use CI/CD pipelines, build scripts, or container images.

---

## Tradeoff 4 -- Direct AWS CLI Invocation vs Public API Endpoint

### What this means

A Lambda function can be tested in multiple ways.

For this project, I invoked it directly with the AWS CLI:

```bash
aws lambda invoke
```

Another option is exposing it publicly through API Gateway.

### What I chose

For Project 6, I used direct AWS CLI invocation.

### Why

Project 6 was focused only on creating and testing Lambda. API Gateway was intentionally saved for Project 7.

This kept the learning sequence clean:

```text
Project 6 -- create serverless compute
Project 7 -- expose serverless compute through HTTP API
```

### The tradeoff

Direct invocation is good for testing and automation, but normal users do not call Lambda from the AWS CLI.

A public web or application client usually needs an HTTP endpoint, which is why API Gateway was added in Project 7.

Cloud engineering takeaway: Lambda is the backend compute. API Gateway is the public front door.

---

## Lessons Learned

* Lambda allows code to run without managing servers.
* Lambda functions need a handler as the entry point.
* The handler format connects the file name and function name.
* Python Lambda code must be packaged before upload.
* Terraform can package Lambda code using the archive provider.
* Lambda needs an IAM execution role before it can run.
* The trust policy allows the Lambda service to assume the role.
* The `AWSLambdaBasicExecutionRole` policy allows Lambda to write logs to CloudWatch.
* `source_code_hash` helps Terraform detect Lambda code changes.
* `response.json` is useful for testing but should not be committed.
* `.terraform.lock.hcl` should be committed.
* `terraform.tfstate` should not be committed.
* Direct AWS CLI invocation is a good first test before adding API Gateway.
* Project 6 created the backend function that Project 7 later exposed through a public API.
* Keeping `resil-hello-lambda` live was intentional because it was needed for the next project.

---

## How to Deploy

```bash
# Clone the repo
git clone https://github.com/TGLEE4/resil-project-06-lambda.git

# Enter the project folder
cd resil-project-06-lambda

# Initialize Terraform
terraform init

# Format Terraform files
terraform fmt

# Validate Terraform code
terraform validate

# Preview the planned infrastructure
terraform plan

# Deploy the Lambda function and IAM resources
terraform apply

# Confirm with yes when prompted
```

---

## How to Test

```bash
# Invoke the Lambda function and save the response
aws lambda invoke \
  --function-name resil-hello-lambda \
  --cli-binary-format raw-in-base64-out \
  --payload '{}' \
  response.json

# Print the response
cat response.json
```

Expected flow:

```text
AWS CLI invoke command
↓
resil-hello-lambda
↓
Python handler runs
↓
Lambda returns response
↓
response.json stores result
```

---

## How to Destroy

Most project resources should be destroyed when done to avoid unnecessary AWS resources.

However, this project was intentionally kept live because Project 7 needed the Lambda function.

Do not destroy this Lambda if Project 7 still depends on it:

```text
resil-hello-lambda
```

If this project is no longer needed, destroy it with:

```bash
terraform destroy
```

Then confirm:

```text
yes
```

This would destroy the Lambda function and IAM resources managed by this Project 6 Terraform configuration.

Important: only run destroy if no later project depends on this function.

---

## What This Project Demonstrates to Employers

This project demonstrates that I can:

* Build a serverless function with AWS Lambda
* Write a basic Python Lambda handler
* Package Lambda code for deployment
* Use Terraform to manage serverless infrastructure
* Create an IAM execution role for Lambda
* Attach logging permissions for CloudWatch
* Use Terraform outputs for deployed resource details
* Test Lambda directly through the AWS CLI
* Save and inspect a function response
* Use `.gitignore` to keep local state and generated files out of GitHub
* Maintain a clean project repo with documentation
* Build a foundation for API Gateway integration

This is directly relevant to Cloud Infrastructure Engineer work because serverless functions are commonly used for automation, backend APIs, event processing, scheduled jobs, and lightweight cloud workflows.

---

## Final Project Summary

Project 6 created a Python serverless function using AWS Lambda and Terraform.

The final architecture was:

```text
Terraform
↓
IAM execution role
↓
Lambda function
↓
Python handler
↓
AWS CLI test invoke
↓
response.json
```

This project introduced the core serverless idea: running code in AWS without managing a server.

Project 6 proved that I could create and test serverless compute.

Project 7 then built on top of this by exposing the Lambda function through API Gateway.

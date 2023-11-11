variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "lambda_function_description" {
  description = "The description of the Lambda function"
  type        = string
  default     = "This is a sample Lambda function"
}

variable "source_dir" {
  description = "The source directory for the Lambda function"
  type        = string
}

variable "environment" {
  description = "The environment to deploy to"
  type        = string
  default     = "DEV"
}

variable "api_gateway_execution_arn" {
  description = "The ARN of the API Gateway execution"
  type        = string
}

variable "environment_variables" {
  description = "The environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "password" {
  description = "The password for the Lambda function"
  type        = string
  sensitive   = true
}

variable "s3_policy_arn" {
  description = "The ARN of the S3 policy"
  type        = string
}

variable "cmk_policy_arn" {
  description = "The ARN of the CMK policy"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

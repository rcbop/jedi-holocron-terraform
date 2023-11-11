variable "region" {
  description = "The region in which the resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The environment for the API Gateway"
  type        = string
}

variable "username" {
  description = "The username for the API Gateway"
  type        = string
  default     = "luke"
}

variable "password" {
  description = "The password for the API Gateway"
  type        = string
  default     = "skywalker"
  sensitive   = true
}

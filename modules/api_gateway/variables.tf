variable "api_gateway_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "integrations" {
  description = "The integrations for the API Gateway"
  type = map(object({
    integration_description = string
    integration_method      = string
    integration_uri         = string
    integration_route_key   = string
  }))
}

variable "environment" {
  description = "The environment for the API Gateway"
  type        = string
}
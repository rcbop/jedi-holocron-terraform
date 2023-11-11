variable "cmk_description" {
  description = "The description of the CMK"
  type        = string
  default     = "This is a sample CMK"
}

variable "enable_key_rotation" {
  description = "Whether to enable key rotation"
  type        = bool
  default     = true
}

variable "environment" {
  description = "The environment for the CMK"
  type        = string
  default     = "DEV"
}
# modules/iam-key-rotation/variables.tf
variable "username" {
  description = "IAM username for key rotation"
  type        = string
}

variable "key1_enabled" {
  description = "Enable/disable key1 - set to true to create/keep key1"
  type        = bool
  default     = true
}

variable "key2_enabled" {
  description = "Enable/disable key2 - set to true to create/keep key2"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
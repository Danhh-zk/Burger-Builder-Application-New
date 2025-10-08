variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "team5"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "EastUS2"
}

variable "tags" {
  type = map(string)
  default = {
    environment = "dev"
    project     = "team5"
  }
}

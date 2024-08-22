variable "folder_name" {
  description = "Yandex.Cloud folder ID where resources will be created. If it is not provided, the default provider folder is used."
  type        = string
  default     = "default"
}

variable "execution_timeout" {
  description = "Execution timeout in seconds (duration format) for Yandex Cloud Serverless Container."
  type        = string
  default     = "15s"
}

variable "memory" {
  description = "Memory in megabytes (aligned to 128MB) for Yandex Cloud Serverless Container."
  type        = number
  default     = 128
}

variable "cores" {
  description = "Cores (1+) of the Yandex Cloud Serverless Container."
  type        = number
  default     = 1
}

variable "core_fraction" {
  description = "Core fraction (0…100) of the Yandex Cloud Serverless Container."
  type        = number
  default     = 100

#  validation {
#    condition     = contains(can(regex("[0-9]?[0-9]?"), var.core_fraction))
#    error_message = "Core fraction must be 0..100."
#  }
}

variable "docker_image" {
  description = "Atlantis docker image."
  type        = string
  default     = "ghcr.io/runatlantis/atlantis:latest"
}


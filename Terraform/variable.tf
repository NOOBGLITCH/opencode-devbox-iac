variable "aws_region" {
  type        = string
  description = "AWS deployment region"
  default     = "ap-south-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type (Intel Sapphire Rapids, 2 vCPU, 4GB RAM)"
  default     = "c7i-flex.large"
}

variable "key_name" {
  type        = string
  description = "Name of existing AWS EC2 Key Pair for SSH"
  default     = "devbox-key"
}

variable "volume_size" {
  type        = number
  description = "Root disk size in GB"
  default     = 50
}

variable "aws_region" {
  description = "AWS Region in which resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Size of EC2 instance"
  type        = string
  default     = "t3.medium" # For Jenkins + Docker t3.medium ya t2.medium is recommended.
}

variable "ebs_size" {
  description = "EBS Volume size in GB"
  type        = number
  default     = 30
}

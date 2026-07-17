variable "aws_region" {
  description = "AWS Region jahan resources banenge"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance ka size"
  type        = string
  default     = "t3.medium" # Jenkins + Docker ke liye minimum t3.medium ya t2.medium recommended hai
}

variable "ebs_size" {
  description = "EBS Volume size in GB"
  type        = number
  default     = 30
}
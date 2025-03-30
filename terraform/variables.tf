variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "instance_categories" {
  description = "Instance categories for Karpenter node pool (t2 and m5 families)"
  type        = list(string)
  default     = ["t", "m"]
}

variable "instance_cpu_values" {
  description = "CPU values for Karpenter node pool (small instances)"
  type        = list(string)
  default     = ["1", "2", "4"]
}

variable "node_pool_cpu_limit" {
  description = "CPU limit for Karpenter node pool (total CPU cores)"
  type        = number
  default     = 100
}

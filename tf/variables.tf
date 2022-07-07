variable "region" {
  description = "Allowed AWS regions for deployments (eu-west-1,af-south-1)"
  type        = string
  default     = "af-south-1"
  validation {
    condition     = contains(["eu-west-1", "af-south-1"], var.region)
    error_message = "ERROR: Invalid AWS region for deployments. Valid regions are eu-west-1 or af-south-1."
  }
}
variable "environment" {
  description = "Name of deploy environment eg, dev for given resources"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev"], var.environment)
    error_message = "ERROR: Invalid deployment environment. Valid environment names are dev, int, uat, prod, shared-dev and shared-prod."
  }
}

variable "project_name" {
  description = "Name of project. This is automatically configured by oneDeploy for prod deployments"
  type        = string
}

variable "team_name" {
  description = "Team who owns this project. This is automatically configured by oneDeploy for prod deployments"
  type        = string
}

variable "deployer_name" {
  description = "Name of person who deployed this project. This is automatically configured by oneDeploy for prod deployments"
  type        = string
}

variable "bm_number_of_events" {
  description = "Number of benchmark events"
  type        = string
  default     = "30000"
}

variable "bm_number_of_projects" {
  description = "Number of benchmark projects"
  type        = string
  default     = "30000"
}

variable "benchmarking_suite_image" {
  description = "Name of benchmark image including registry and version"
  type        = string
  default     = "135703251640.dkr.ecr.af-south-1.amazonaws.com/tool-benchmarking-suite:fs-mark"
}

variable "container_benchmark_image" {
  description = "Name of benchmark image including registry and version"
  type        = string
  default     = "135703251640.dkr.ecr.af-south-1.amazonaws.com/tool-container-benchmark:d815497f"
}

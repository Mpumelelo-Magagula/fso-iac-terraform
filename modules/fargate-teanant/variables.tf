# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------
variable "aws_region" {
  description = "region to use"
  default = "eu-west-1"
}


variable "service_name" {
  description = "The name of the Fargate service to run"
  type        = string
  default     = "client1-fso"
}
variable "service_name_web_api" {
  description = "The name of the service. This is used to namespace all resources created by this module."
  default = "web-api-client1-fso"
  type        = string
}

variable "desired_number_of_tasks" {
  description = "How many instances of the container to schedule on the cluster"
  type        = number
  default     = 1
}

variable "http_port_web_api" {
  description = "The port on which the host and container listens on for HTTP requests"
  type        = number
  default     = 8082
}


variable "http_port_shared_data" {
  description = "The port on which the host and container listens on for HTTP requests"
  type        = number
  default     = 5000
}
variable "http_port_activation_stream" {
  description = "The port on which the host and container listens on for HTTP requests"
  type        = number
  default     = 4000
}
variable "http_port_data_stream_loader" {
  description = "The port on which the host and container listens on for HTTP requests"
  type        = number
  default     = 8080
}
variable "http_port_data_stream_mapper" {
  description = "The port on which the host and container listens on for HTTP requests"
  type        = number
  default     = 3000
}

variable "server_text" {
  description = "The fsoker container we run in this example will display this text for every request."
  type        = string
  default     = "Hello"
}


variable "route53_hosted_zone_name" {
  description = "The name of the Route53 Hosted Zone where we will create a DNS record for this service (e.g. gruntwork-dev.io)"
  type        = string
  default     = "asi-observability.net"
}

variable "enable_ecs_deployment_check" {
  description = "Whether or not to enable ECS deployment check. This requires installation of the check-ecs-service-deployment binary. See the ecs-deploy-check-binaries module README for more information."
  type        = bool
  default     = false
}

variable "deployment_check_timeout_seconds" {
  description = "Number of seconds to wait for the ECS deployment check before giving up as a failure."
  type        = number
  default     = 600
}

variable "container_command" {
  description = "Command to run on the container. Set this to see what happens when a container is set up to exit on boot"
  type        = list(string)
  default     = []
  # Related issue: https://github.com/hashicorp/packer/issues/7578
  # Example:
  # default = ["-c", "/bin/sh", "echo", "Hello"]
}


variable "tenants"{
  type = string
  default = "xyz"

}

variable "vpc_id" {
  type = string
  description = "vpc used"
}

variable "subnet_ids" {
  type = list(string)
  description = "private subnets"
}

variable "customer" {
  description = "The name of the teanant."
  type        = string
  default     = "client1"
}

variable "environment" {
  description = "The name of the enviroment dev/stage/prod."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "The name of the aws region."
  type        = string
  default     = "eu-west-1"
}
variable "application" {
  description = "The name of the application."
  type        = string
  default     = "fso-test"
}
variable "vpc" {
  description = "The name of the vpc."
  type        = string
  default     = "fso-vpc"
}



variable "ecs_cidr" {
  type = list(string)
  description = "cidr block for ecs"
}
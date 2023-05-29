variable "num_read_replicas" {
  description = "The number of read replicas to deploy"
  type        = number
  default     = 1
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = true
}

variable "rds_subnet_ids" {
  type = list(string)
  description = "private subnets"
}
variable "security_groups" {
  type = list(string)
  description = "secuirty groups"
}

variable "proxy_security_group" {
  type = list(string)
}

variable "ssm_arn" {
  type = string
}
variable "bastion_subnet" {
  type = string
}
variable "assign_public_ip" {
  description = "Assign public IP - required for image pull if spinning up in a public subnet with no NAT gateway or instance"
  type        = bool
  default     = true
}
#
#variable "log_agent_group_name" {
#  description = "Name for the Cloudwatch Log Group for agent logging"
#  type        = string
#  default     = "csm-proto-2"
#}


variable "vpc_id" {
  type        = string
}

variable "region" {
  description = "test or prod env"
  default = "eu-west-1"
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


variable "secret_tags" {
  type        = map(string)
  default     = {
    owner=  "tenant"
    customer = "client1"
    }
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



variable "engine" {
  default = "mysql"
  
}

variable "dbname" {
  default = "fso_db"
  
}


variable "username" {
  default = "admin"
  
}

#More clarification???..................
variable "identifier" {
  default = "fso_db"
}




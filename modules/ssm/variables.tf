
variable "vpc_id" {
  default = "aws_vpc.Main.id"
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
    owner= "tenant"
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
variable "dbpass" {
  
}
variable "rdsproxy_host" {
  type = string
}
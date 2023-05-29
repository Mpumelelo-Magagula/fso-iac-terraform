variable "env" {
  description = "test or prod env"
}
variable "email" {
  description = "testing email"
  type        = string
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


variable "assign_public_ip" {
  description = "Assign public IP - required for image pull if spinning up in a public subnet with no NAT gateway or instance"
  type        = bool
  default     = true
}


variable "execution_role_arn" {
  description = "The ARN of the role ECS will use to initialise the task."
  default     = "arn:aws:iam::56240058865:role/ecsTaskExecutionRole"
}





variable "vpc_id" {
  default = "aws_vpc.Main.id"
}



variable "service_name" {
  description = "The name of the ECS Service you want these task(s) to run under."
  type        = string
  default     = "fso-dev-node-app-service"
}

variable "subnet_ids" {
  description = "A list of subnets you wish these tasks to be able to run in."
  type=list
  default=["aws_subnet.privatesubnets.id", "aws_subnet.publicsubnets.id"]
}


variable "aws_region" {
  description = "region to use"
}

variable "availablity_zoneA" {
  description = "az for subnets"
  type        = string
}
variable "availablity_zoneB" {
  description = "az for subnet"
  type        = string
  
}

variable "secret_name" {
  description = "id of ssm."
  default = "aws_secretsmanager_secret.secret_manager.name"
}
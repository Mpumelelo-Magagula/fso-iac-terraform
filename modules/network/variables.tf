variable "availablity_zoneA" {
  description = "az for subnets"
  type        = string
}
variable "availablity_zoneB" {
  description = "az for subnet"
  type        = string
  
}

variable "assign_public_ip" {
  description = "Assign public IP - required for image pull if spinning up in a public subnet with no NAT gateway or instance"
  type        = bool
  default     = true
}



variable "vpc_id" {
  default = "aws_vpc.Main.id"
}



variable "subnet_ids" {
  description = "A list of subnets you wish these tasks to be able to run in."
  type=list
  default=["aws_subnet.privatesubnetsa.id","aws_subnet.privatesubnetsb.id"]
}
variable "rds_subnet_ids" {
  description = "A list of subnets for rds to be able to run in."
  type=list
  default=["aws_subnet.privatesubnetsc.id","aws_subnet.privatesubnetsd.id"]
}



# The port the load balancer will listen on
variable "lb_port" {
  default = "80"
}

# The load balancer protocol
variable "lb_protocol" {
  default = "TCP"
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

variable "vpc_cidrblock" {
  default = "10.0.0.0/16"
}

variable "publiccidrblockA" {
  default = "10.0.0.0/24" 
}

variable "publiccidrblockB" {
  default = "10.0.1.0/24" 
}

variable "privatecidrblockA" {
  default = "10.0.2.0/24"  
}

variable "privatecidrblockB" {
  default = "10.0.3.0/24"  
}


variable "route_table_cidr" {
  default = "0.0.0.0/0" 
}
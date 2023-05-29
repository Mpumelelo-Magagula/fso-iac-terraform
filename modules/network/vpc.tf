resource "aws_vpc" "default" {                # Creating VPC here
   cidr_block       = var.vpc_cidrblock
   instance_tenancy = "default"
   #Name= "vpc-${var.customer}-${var.environment}-${var.region}"
  tags = {
    Name = "vpc-${var.customer}-${var.environment}-${var.region}"
    #"fso:operations:managed_by" = "fsosupport@fso.io"
    "fso:cost_control.client_id" = "${var.customer}"
    "fso:operations:environment" = "${var.environment}"
    "fso:governance:tagging_version" = "V1.0"
    "fso:operations:layer_id"   = "SecurityService"
    "fso:access_control:security_zone" = "RestrictedZone"
  }
 }

 #Create Internet Gateway and attach it to VPC
 resource "aws_internet_gateway" "IGW" {    
    vpc_id =  aws_vpc.default.id               # vpc_id will be generated after we create VPC
    tags =  {
      Name = "igtw-${var.customer}-${var.environment}-${var.region}"
      #"fso:operations:managed_by" = "fsosupport@fso.io"
      "fso:cost_control.client_id" = "${var.customer}"
      "fso:operations:environment" = "${var.environment}"
      "fso:governance:tagging_version" = "V1.0"
      "fso:operations:layer_id"   = "SecurityService"
      "fso:access_control:security_zone" = "RestrictedZone"
    
      }
 }
 #Create a Public Subnets.
 resource "aws_subnet" "publicsubnetsa" {    
   availability_zone       = var.availablity_zoneA
   vpc_id                  = aws_vpc.default.id
   cidr_block              = var.publiccidrblockA    
   map_public_ip_on_launch = true
      tags =  {
      Name = "snet-public1-${var.customer}-${var.environment}-${var.region}"
      #"fso:operations:managed_by" = "fsosupport@fso.io"
      "fso:cost_control.client_id" = "${var.customer}"
      "fso:operations:environment" = "${var.environment}"
      "fso:governance:tagging_version" = "V1.0"
      "fso:operations:layer_id"   = "SecurityService"
      "fso:access_control:security_zone" = "RestrictedZone"
      }

 }
 resource "aws_subnet" "publicsubnetsb" {    
   availability_zone       = var.availablity_zoneB
   vpc_id                  = aws_vpc.default.id
   cidr_block              = var.publiccidrblockB  
   map_public_ip_on_launch = true
      tags =  {
      Name = "snet-public2-${var.customer}-${var.environment}-${var.region}"
      #"fso:operations:managed_by" = "fsosupport@fso.io"
      "fso:cost_control.client_id" = "${var.customer}"
      "fso:operations:environment" = "${var.environment}"
      "fso:governance:tagging_version" = "V1.0"
      "fso:operations:layer_id"   = "SecurityService"
      "fso:access_control:security_zone" = "RestrictedZone"
      }

 }

 #Create a Private Subnet                   
 resource "aws_subnet" "privatesubnetsa" { # for ecs services 
   availability_zone       = var.availablity_zoneA
   vpc_id                  = aws_vpc.default.id
   cidr_block              = var.privatecidrblockA   
         tags =  {
      Name = "snet-private1-${var.customer}-${var.environment}-${var.region}"
     # "fso:operations:managed_by" = "fsosupport@fso.io"
      "fso:cost_control.client_id" = "${var.customer}"
      "fso:operations:environment" = "${var.environment}"
      "fso:governance:tagging_version" = "V1.0"
      "fso:operations:layer_id"   = "SecurityService"
      "fso:access_control:security_zone" = "RestrictedZone"
      }
    
 }

resource "aws_subnet" "privatesubnetsb" {    #for ecs services 
   availability_zone       = var.availablity_zoneB 
   vpc_id                  = aws_vpc.default.id
   cidr_block              = var.privatecidrblockB     
  #$map_public_ip_on_launch = true
        tags =  {
      Name = "snet-private2-${var.customer}-${var.environment}-${var.region}"
     # "fso:operations:managed_by" = "fsosupport@fso.io"
      "fso:cost_control.client_id" = "${var.customer}"
      "fso:operations:environment" = "${var.environment}"
      "fso:governance:tagging_version" = "V1.0"
      "fso:operations:layer_id"   = "SecurityService"
      "fso:access_control:security_zone" = "RestrictedZone"
      }

 }

 #Route table for Public Subnet's 
 resource "aws_route_table" "PublicRT" {    
    vpc_id     = aws_vpc.default.id
         route {
    cidr_block = var.route_table_cidr              # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.IGW.id
     }
           tags =  {
      Name = "rtb-${var.customer}-${var.environment}-${var.region}-pub"
      #"fso:operations:managed_by" = "fsosupport@fso.io"
      "fso:cost_control.client_id" = "${var.customer}"
      "fso:operations:environment" = "${var.environment}"
      "fso:governance:tagging_version" = "V1.0"
      "fso:operations:layer_id"   = "SecurityService"
      "fso:access_control:security_zone" = "RestrictedZone"
      }

 }
 #Route table for Private Subnet's
 resource "aws_route_table" "PrivateRTA" {    
   vpc_id         = aws_vpc.default.id
   route {
   cidr_block     = var.route_table_cidr            # Traffic from Private Subnet reaches Internet via NAT Gateway
   nat_gateway_id = aws_nat_gateway.NATgw.id
   }
    tags =  {
      Name = "rtb-${var.customer}-${var.environment}-${var.region}-prv"
      #"fso:operations:managed_by" = "fsosupport@fso.io"
      "fso:cost_control.client_id" = "${var.customer}"
      "fso:operations:environment" = "${var.environment}"
      "fso:governance:tagging_version" = "V1.0"
      "fso:operations:layer_id"   = "SecurityService"
      "fso:access_control:security_zone" = "RestrictedZone"
      }

 }

  resource "aws_route_table" "PrivateRTB" {    
   vpc_id         = aws_vpc.default.id
   route {
   cidr_block     = var.route_table_cidr            # Traffic from Private Subnet reaches Internet via NAT Gateway
   nat_gateway_id = aws_nat_gateway.NATgw.id
   }
    tags =  {
      Name = "rtb-${var.customer}-${var.environment}-${var.region}-prv"
      #"fso:operations:managed_by" = "fsosupport@fso.io"
      "fso:cost_control.client_id" = "${var.customer}"
      "fso:operations:environment" = "${var.environment}"
      "fso:governance:tagging_version" = "V1.0"
      "fso:operations:layer_id"   = "SecurityService"
      "fso:access_control:security_zone" = "RestrictedZone"
      }

 }


 #Route table Association with Public Subnet's
 resource "aws_route_table_association" "PublicRTassociationa" {
    subnet_id      = aws_subnet.publicsubnetsa.id
    route_table_id = aws_route_table.PublicRT.id


 }
  resource "aws_route_table_association" "PublicRTassociationb" {
    subnet_id      = aws_subnet.publicsubnetsb.id
    route_table_id = aws_route_table.PublicRT.id


 }
 #Route table Association with Private Subnet's
 resource "aws_route_table_association" "PrivateRTassociationa" {
    subnet_id      = aws_subnet.privatesubnetsa.id 
    route_table_id = aws_route_table.PrivateRTA.id

 }
resource "aws_route_table_association" "PrivateRTassociationb" {
    subnet_id      = aws_subnet.privatesubnetsb.id
    route_table_id = aws_route_table.PrivateRTB.id

 }
#resource "aws_route_table_association" "PrivateRTassociationc" {
#    subnet_id      = aws_subnet.privatesubnetsc.id
#    route_table_id = aws_route_table.PrivateRTC.id
#
# }
#resource "aws_route_table_association" "PrivateRTassociationd" {
#
#    subnet_id      = aws_subnet.privatesubnetsd.id
#    route_table_id = aws_route_table.PrivateRTD.id
#   #tags or name can't be here error : argument named "tags" "name" is not expected here.
# }

 resource "aws_eip" "nateIP" {
   vpc   = true
   tags =  {
      Name = "natip-${var.customer}-${var.environment}-${var.region}"
      #"fso:operations:managed_by" = "fsosupport@fso.io"
      "fso:cost_control.client_id" = "${var.customer}"
      "fso:operations:environment" = "${var.environment}"
      "fso:governance:tagging_version" = "V1.0"
      "fso:operations:layer_id"   = "NetworkService"
      "fso:access_control:security_zone" = "RestrictedZone"
      }
 }
 #Creating the NAT Gateway using subnet_id and allocation_id
 resource "aws_nat_gateway" "NATgw" {
   allocation_id = aws_eip.nateIP.id
   subnet_id     = aws_subnet.publicsubnetsa.id
   tags =  {
      Name = "gtw-nat-${var.customer}-${var.environment}-${var.region}"
     # "fso:operations:managed_by" = "fsosupport@fso.io"
      "fso:cost_control.client_id" = "${var.customer}"
      "fso:operations:environment" = "${var.environment}"
      "fso:governance:tagging_version" = "V1.0"
      "fso:operations:layer_id"   = "SecurityService"
      "fso:access_control:security_zone" = "RestrictedZone"
    
      }
 }


####### secuirty group for rds  proxy ##########

resource "aws_security_group" "rds_proxy_sg" {
  description = "rds proxy sg"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
  }

  name = "rds-proxy-sg-${var.customer}-${var.environment}-${var.region}"
  vpc_id = aws_vpc.default.id
  tags =  {
      Name = "rds-proxy-sg-${var.customer}-${var.environment}-${var.region}"
      #"fso:operations:managed_by" = "fsosupport@fso.io"
      "fso:cost_control.client_id" = "${var.customer}"
      "fso:operations:environment" = "${var.environment}"
      "fso:governance:tagging_version" = "V1.0"
      "fso:operations:layer_id"   = "SecurityService"
      "fso:access_control:security_zone" = "RestrictedZone"
      }
}

####### secuirty group for rds  ##########

resource "aws_security_group" "rds_sg" {
  description = "SG for rds instance"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    security_groups = [aws_security_group.rds_proxy_sg.id]
    #cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
  }

  name = "rds-db-sg-${var.customer}-${var.environment}-${var.region}"
  vpc_id = aws_vpc.default.id
   tags =  {
      Name = "rds-db-sg-${var.customer}-${var.environment}-${var.region}"
      #"fso:operations:managed_by" = "fsosupport@fso.io"
      "fso:cost_control.client_id" = "${var.customer}"
      "fso:operations:environment" = "${var.environment}"
      "fso:governance:tagging_version" = "V1.0"
      "fso:operations:layer_id"   = "SecurityService"
      "fso:access_control:security_zone" = "RestrictedZone"
      }
}



####### outputs ##########

output "aws_vpc"{
  value = aws_vpc.default.id
}

output "ecs-private-subnet" {
  value = [
    aws_subnet.privatesubnetsa.id,
    aws_subnet.privatesubnetsb.id
  ]
}


output "vpclink-public-subnet" {
  value = [
    aws_subnet.publicsubnetsa.id,
    #aws_subnet.privatesubnetsb.id
  ]
}

output "bastion-public-subnet" {
  value = aws_subnet.publicsubnetsb.id
  
}
output "rds-sg" {
  value = [
    aws_security_group.rds_sg.id,
  ]
}
output "rds-proxy-sg" {
  value = [
    aws_security_group.rds_proxy_sg.id,
  ]
}
output "rds-private-subnet" {
  value = [
   aws_subnet.privatesubnetsa.id,
   aws_subnet.privatesubnetsb.id
  ]
}

output "ecs_cidr"{
value = [
  aws_subnet.privatesubnetsa.cidr_block,
  aws_subnet.privatesubnetsb.cidr_block
]
}
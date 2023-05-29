module "network" {
  source  = "./modules/network"
  availablity_zoneA =  "${var.availablity_zoneA}"
  availablity_zoneB  =  "${var.availablity_zoneB}"

  
}


module "ssm" {
  source  = "./modules/ssm"
  dbpass = module.rds.password
  rdsproxy_host = module.rds.rdsproxy_enp
  
}


module "fargate-teanant" {
  source  = "./modules/fargate-teanant"
  vpc_id = module.network.aws_vpc
  subnet_ids = module.network.ecs-private-subnet
  ecs_cidr = module.network.ecs_cidr
  
  
}


module "rds" {
  source  = "./modules/database"
  rds_subnet_ids = module.network.rds-private-subnet
  security_groups = module.network.rds-sg
  proxy_security_group = module.network.rds-proxy-sg
  ssm_arn = module.ssm.ssm-arn
  bastion_subnet =  module.network.bastion-public-subnet
  vpc_id = module.network.aws_vpc
 
}


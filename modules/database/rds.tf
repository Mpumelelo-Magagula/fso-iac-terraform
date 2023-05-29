
resource "aws_db_proxy" "rds_proxy" {
  name                   = "mysql-${var.customer}-${var.environment}-${var.region}-rds-proxy"
  debug_logging          = false
  engine_family          = "MYSQL"
  idle_client_timeout    = 1800
  require_tls            = false
  role_arn               = aws_iam_role.rds_proxy_role.arn
  vpc_security_group_ids = var.proxy_security_group
  vpc_subnet_ids         = var.rds_subnet_ids

  auth {
    auth_scheme = "SECRETS"
    description = "example"
    iam_auth    = "DISABLED"
    secret_arn  = var.ssm_arn
  }

  tags = {
    Name = "mysql-${var.customer}-${var.environment}-${var.region}-rds-proxy"
    "fso:operations:environment" = "${var.environment}"
    "fso:cost_control.client_id" = "${var.customer}"
    "fso:governance:tagging_version" = "V1.0"
    "fso:operations:layer_id"   = "ApplicationService"
    "fso:access_control:security_zone" = "RestrictedZone"
  }
}



# resource "aws_db_proxy_endpoint" "rds_proxy_endp" {
#   db_proxy_name          = aws_db_proxy.rds_proxy.name
#   db_proxy_endpoint_name = "mysql-${var.customer}-${var.environment}-rds-proxy-endp"
#   vpc_subnet_ids         = var.rds_subnet_ids
#   target_role            = "READ_WRITE"
# }



resource "aws_db_proxy_default_target_group" "rds_proxy_tg" {
  db_proxy_name = aws_db_proxy.rds_proxy.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    #init_query                   = "SET x=1, y=2"
    max_connections_percent      = 100
    max_idle_connections_percent = 50
   # session_pinning_filters      = ["NONE"] #["EXCLUDE_VARIABLE_SETS"]
  }
#tags cant be entered here nor name
}

resource "aws_db_proxy_target" "rds_proxy_target" {
  db_instance_identifier = aws_db_instance.client1-fso-db.id
  db_proxy_name          = aws_db_proxy.rds_proxy.name
  target_group_name      = aws_db_proxy_default_target_group.rds_proxy_tg.name
#tags cant be entered here nor name
}

resource "random_password" "password" {
length = 16
special = false
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "sng-${var.customer}-${var.environment}-${var.region}"
  subnet_ids = var.rds_subnet_ids
    tags = {
    Name = "subnet-group-${var.customer}-${var.environment}-${var.region}"
    "fso:operations:environment" = "${var.environment}"
    "fso:cost_control.client_id" = "${var.customer}"
    "fso:governance:tagging_version" = "V1.0"
    "fso:operations:layer_id"   = "SecurityService"
    "fso:access_control:security_zone" = "RestrictedZone"
  }
}

resource "aws_db_instance" "client1-fso-db" {
  identifier           = "mysql-${var.customer}-${var.environment}-rds"
  allocated_storage    = 20
  #storage_type         = "gp3"
  engine               = var.engine
  engine_version       = "8.0.28" 
  instance_class       = "db.t3.medium"
  db_name              = var.dbname
  username             = var.username
  password             = random_password.password.result
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  port                 = 3306
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.id
  multi_az             = var.multi_az
  vpc_security_group_ids = var.security_groups
  #security_group_names = var.security_groups

  #num_read_replicas    = var.num_read_replicas
    tags = {
    Name = "mysql-${var.customer}-${var.environment}-${var.region}-rds"
    "fso:cost_control.client_id" = "${var.customer}"
    "fso:operations:environment" = "${var.environment}"
    "fso:governance:tagging_version" = "V1.0"
    "fso:operations:layer_id"   = "Ingestion"
    "fso:access_control:security_zone" = "RestrictedZone"
  }
}





################################################################################
                                #rds proxy role 
##################################################################################



resource "aws_iam_role" "rds_proxy_role" {
  name = "rds-proxy-role-${var.customer}-${var.environment}-${var.region}"
  inline_policy {
  name   = "rds-proxy-secret-policy"
  policy = data.aws_iam_policy_document.rds_proxy_policy.json
  }
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    name = "rds proxy"
  }
}


  data "aws_iam_policy_document" "rds_proxy_policy" {
  statement {
    effect = "Allow"

    actions = [

      "secretsmanager:*",
    ]

    resources = ["*"]
  }
}

###########################################################################
                          #rds bastion server
###########################################################################

data "aws_ami" "bastion_ami" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220609"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}



locals {
  cloud_config_config = <<-END
    #cloud-config
    ${jsonencode({
      write_files = [
        {

        },
        
      ]
    })}
  END
}

resource "aws_eip" "bastion_lb" {
  instance = aws_instance.bastion_instance.id
  vpc      = true
  tags = {
    Name = "bastion-eip-${var.customer}-${var.environment}-${var.region}"
    "fso:operations:environment" = "${var.environment}"
    "fso:cost_control.client_id" = "${var.customer}"
  }
}


  resource "aws_instance" "bastion_instance" {
  ami                    = data.aws_ami.bastion_ami.id

  instance_type          = "t2.micro"
  subnet_id              = var.bastion_subnet
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = "bastion-key"
  #user_data              = local.cloud_config_config


  tags = {
    Name = "ec2-bastion-server-${var.customer}-${var.environment}-${var.region}"
    "fso:operations:environment" = "${var.environment}"
    #"fso:operations:managed_by" = "fsosupport@fso.io"
    "fso:cost_control.client_id" = "${var.customer}"
  }

  }

resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg-${var.customer}-${var.environment}-${var.region}"
   tags =  {
      Name = "bastion-sg-${var.customer}-${var.environment}-${var.region}"
      #"fso:operations:managed_by" = "fsosupport@fso.io"
      "fso:cost_control.client_id" = "${var.customer}"
      "fso:operations:environment" = "${var.environment}"
      "fso:governance:tagging_version" = "V1.0"
      "fso:operations:layer_id"   = "SecurityService"
      "fso:access_control:security_zone" = "RestrictedZone"
    
      }
  vpc_id = var.vpc_id

  ingress {
    description      = "bastion server ports"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


output "password" {
  value =random_password.password.result
  
}

 output "rdsproxy_enp"{
   value = aws_db_proxy.rds_proxy.endpoint
 }
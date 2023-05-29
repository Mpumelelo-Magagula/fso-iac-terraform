
# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CLUSTER TO WHICH THE FARGATE SERVICE WILL BE DEPLOYED TO
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_cluster" "fargate_cluster" {
  name = "ecs-${var.customer}-${var.environment}-${var.region}"
  tags = {
    Name = "ecs-${var.customer}-${var.environment}-${var.region}"
    "fso:operations:environment" = "${var.environment}"
    "fso:cost_control.client_id" = "${var.customer}"
    "fso:governance:tagging_version" = "V1.0"
    "fso:operations:layer_id"   = "Processing"
    "fso:access_control:security_zone" = "RestrictedZone"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A FARGATE SERVICE TO RUN MY ECS TASK
# ---------------------------------------------------------------------------------------------------------------------

module "fargate_service" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-ecs.git//modules/ecs-service-fso-test?ref=v1.0.8"
  source = "../ecs-service-fso-test"

  service_name    = "fso-test-${var.customer}-${var.environment}-${var.region}"
#tags cant be added here
  ecs_cluster_arn = aws_ecs_cluster.fargate_cluster.arn

  desired_number_of_tasks        = var.desired_number_of_tasks
  ecs_task_container_definitions = local.container_definition
  launch_type                    = "FARGATE"

  # Network information is necessary for Fargate, as it required VPC type
  ecs_task_definition_network_mode = "awsvpc"
  ecs_service_network_configuration = {
  subnets          = var.subnet_ids
  security_groups  = [aws_security_group.ecs_task_security_group.id]
  assign_public_ip = true
  }

  # https://fsos.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-tasks-size.
  # Specify memory in MB
  task_cpu    = 256
  task_memory = 512

  # Configure alb
  elb_target_groups = {
    alb = {
      name  = "shared-tg-${var.customer}-${var.environment}-${var.region}"
        tags = {
    Name = "shared-data-${var.customer}-${var.environment}-${var.region}"
    "fso:operations:environment" = "${var.environment}"
    "fso:cost_control.client_id" = "${var.customer}"
    "fso:governance:tagging_version" = "V1.0"
    "fso:operations:layer_id"   = "Presentation"
    "fso:access_control:security_zone" = "RestrictedZone"
  }
      container_name        = "shared-data-access-${var.customer}-${var.environment}-${var.region}"
      container_port        = var.http_port_shared_data
      protocol              = "TCP"
      health_check_protocol = "TCP"

    }
  }
  elb_target_group_vpc_id = data.aws_vpc.default.id

  health_check_healthy_threshold   = 5
  health_check_unhealthy_threshold = 5

  # Give the container 30 seconds to boot before having the alb start checking health
  health_check_grace_period_seconds = 30

  enable_ecs_deployment_check      = var.enable_ecs_deployment_check
  deployment_check_timeout_seconds = var.deployment_check_timeout_seconds

  # Make sure all the ECS cluster and alb resources are deployed before deploying any ECS service resources. This is
  # also necessary to avoid issues on 'destroy'.
  #depends_on = [aws_ecs_cluster.fargate_cluster, aws_lb.alb]
}

# This local defines the fsoker containers we want to run in our ECS Task
locals {
  container_definition = templatefile(
    "${path.module}/containers/container-definition-fso-test.json",
    {
      container_name = "shared-data-access-${var.customer}-${var.environment}-${var.region}"
      # For this example, we run the fsoker container defined under examples/example-fsoker-image.
      image          = "shared-data-access-layer"
      version        = "latest"
      server_text    = var.server_text
      aws_region     = var.aws_region
      cpu            = 256
      memory         = 512
      awslogs_group  = var.service_name
      awslogs_region = var.aws_region
      awslogs_prefix = var.service_name
      # Container and host must listen on the same port for Fargate
      container_http_port = var.http_port_shared_data
      command             = "[${join(",", formatlist("\"%s\"", var.container_command))}]"
    },
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP FOR THE AWSVPC TASK NETWORK
# Allow all inbound access on the container port and outbound access
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "ecs_task_security_group" {
  
  name   = "ecs-services-sg-${var.customer}-${var.environment}-${var.region}"
  tags = {
  Name = "ecs-services-sg-${var.customer}-${var.environment}-${var.region}"
  "fso:operations:environment" = "${var.environment}"
  "fso:cost_control.client_id" = "${var.customer}"
  "fso:governance:tagging_version" = "V1.0"
  "fso:operations:layer_id"   = "SecurityService"
  "fso:access_control:security_zone" = "RestrictedZone"
  }
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_outbound_all" {
  security_group_id = aws_security_group.ecs_task_security_group.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_inbound_on_container_port" {
  security_group_id = aws_security_group.ecs_task_security_group.id
  type              = "ingress"
  from_port         = var.http_port_data_stream_mapper
  to_port           = var.http_port_web_api
  protocol          = "tcp"
  cidr_blocks       = var.ecs_cidr

}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ALB TO ROUTE TRAFFIC ACROSS THE ECS TASKS
# Typically, this would be created once for use with many different ECS Services.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb" "alb" {
  name = "alb-${var.customer}-${var.environment}-${var.region}"
  tags = {
  Name = "alb-${var.customer}-${var.environment}-${var.region}"
  "fso:operations:environment" = "${var.environment}"
  "fso:cost_control.client_id" = "${var.customer}"
  "fso:governance:tagging_version" = "V1.0"
  "fso:operations:layer_id"   = "ApplicationService"
  "fso:access_control:security_zone" = "RestrictedZone"
  }
  internal                         = true
  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = false
  ip_address_type                  = "ipv4"
  subnets                          = var.subnet_ids
  #count = "${length(data.aws_subnets.default)}"

}

# --------------------------------------------------------------------------------------------------------------------
# GET VPC AND SUBNET INFO FROM TERRAFORM DATA SOURCE
# --------------------------------------------------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = false
  id = var.vpc_id
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# GET VPC AND SUBNET INFO FROM TERRAFORM DATA SOURCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 5000
  protocol          = "TCP"

  default_action {
    target_group_arn = module.fargate_service.target_group_arns["alb"]
    type             = "forward"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ASSOCIATE A DNS RECORD WITH OUR alb
# This way we can test the host-based routing properly.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_route53_zone" "fso" {
  #name = var.route53_hosted_zone_name
  zone_id = "Z09031823NC8WL70Q9APP"
  vpc_id = data.aws_vpc.default.id
  private_zone = false
}

resource "aws_route53_record" "alb_endpoint" {
  zone_id = data.aws_route53_zone.fso.zone_id
  name    = "endp-${var.customer}-${var.environment}-${var.region}-${var.customer}-${var.environment}-${var.region}.${data.aws_route53_zone.fso.name}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ROUTE53 DOMAIN NAME TO BE ASSOCIATED WITH THIS FARGATE SERVICE
# The Route53 Resource Record Set (DNS record) will point to the alb.
# ---------------------------------------------------------------------------------------------------------------------

# Create a DNS Record in Route53 for the ECS Service
# - We are creating a Route53 "alias" record to take advantage of its unique benefits such as instant updates when an
#   alb's underlying nodes change.
# - We set alias.evaluate_target_health to false because Amazon uses these health checks to determine if, in a complex
#   DNS routing tree, it should "back out" of using this DNS Record in favor of another option, and we do not expect
#   such a complex routing tree to be in use here.
resource "aws_route53_record" "fargate_service" {
  zone_id = "Z09031823NC8WL70Q9APP"
  name    = "service.${var.customer}-${var.environment}-${var.region}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP FOR THE AWSVPC TASK NETWORK
# Allow all inbound access on the container port and outbound access
# ---------------------------------------------------------------------------------------------------------------------


# This local defines the fsoker containers we want to run in our ECS Task
locals {
  container_definition_fso_test = templatefile(
    "${path.module}/containers/container-definition-fso-test.json",
    {
      container_name = "fso-test-${var.customer}-${var.environment}-${var.region}"
      # For this example, we run the fsoker container defined under examples/example-fsoker-image.
      image          = "fso-test"
      version        = "latest"
      server_text    = var.server_text
      aws_region     = var.aws_region
      cpu            = 256
      memory         = 512
      awslogs_group  = "fso-test-${var.customer}-${var.environment}-${var.region}"
      awslogs_region = var.aws_region
      awslogs_prefix = "fso-test-${var.customer}-${var.environment}-${var.region}"
      secret =  "ssm-${var.customer}-${var.environment}-${var.region}"
      # Container and host mmust listen on the same port for Fargate
      container_http_port = var.http_port_web_api
      command             = "[${join(",", formatlist("\"%s\"", var.container_command))}]"
    },
  )
}

resource "aws_lb_listener" "fso-test" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 4000
  protocol          = "TCP"

  default_action {
    target_group_arn = module.fargate_service.target_group_arns["alb"]
    type             = "forward"
  }
}



///////////////////////////////////////////////////////////////////////////
                            # API GATEWAY #
///////////////////////////////////////////////////////////////////////////
/*resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "api-${var.customer}-${var.environment}-${var.region}"
    tags = {
  Name = "api-gateway-${var.customer}-${var.environment}-${var.region}"
  "fso:operations:environment" = "${var.environment}"
  "fso:cost_control.client_id" = "${var.customer}"
  "fso:operations:environment" = "${var.environment}"
  "fso:governance:tagging_version" = "V1.0"
  "fso:operations:layer_id"   = "ApplicationService"
  "fso:access_control:security_zone" = "RestrictedZone"
  }
  protocol_type = "HTTP"
}


resource "aws_apigatewayv2_stage" "api_gateway" {
  api_id        = aws_apigatewayv2_api.api_gateway.id
  auto_deploy     = true
  name    = "$default"
    tags = {
  Name = "stage-${var.customer}-${var.environment}-${var.region}"
  "fso:operations:environment" = "${var.environment}"
  "fso:cost_control.client_id" = "${var.customer}"
  "fso:governance:tagging_version" = "V1.0"
  "fso:operations:layer_id"   = "ApplicationService"
  "fso:access_control:security_zone" = "RestrictedZone"
  }
}


resource "aws_apigatewayv2_deployment" "api_gateway" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  description = "fso-deployment"

  lifecycle {
    create_before_destroy = true
  }
#  depends_on = [
#    aws_apigatewayv2_route.api_gateway
#  ]
}*/


#for fso-test intergration with api gateway

/*resource "aws_apigatewayv2_integration" "api_gateway_fso_test" {
  api_id           = aws_apigatewayv2_api.api_gateway.id
  description      = "integration for fso-test"
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.fso-test.arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpc_link.id 
}
resource "aws_apigatewayv2_route" "api_gateway_fso_test_integration" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /api/{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.api_gateway_fso_test.id}"
}




resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "vpclink-${var.customer}-${var.environment}-${var.region}"
  security_group_ids = [aws_security_group.vpc_link_sg.id]
  subnet_ids         = var.subnet_ids

  tags = {
  Name = "vpc-link-${var.customer}-${var.environment}-${var.region}"
  "fso:operations:environment" = "${var.environment}"
  "fso:cost_control.client_id" = "${var.customer}"
  "fso:governance:tagging_version" = "V1.0"
  "fso:operations:layer_id"   = "ApplicationService"
  "fso:access_control:security_zone" = "RestrictedZone"
  }
}*/

#####################################################################################
                                #Security group for vpc Link
#####################################################################################

resource "aws_security_group" "vpc_link_sg" {
  description = "vpc link sg"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  name = "vpc-link-sg-${var.customer}-${var.environment}-${var.region}"
  tags = {
  Name = "vpc-link-sg${var.customer}-${var.environment}-${var.region}"
  "fso:operations:environment" = "${var.environment}"
  "fso:cost_control.client_id" = "${var.customer}"
  "fso:governance:tagging_version" = "V1.0"
  "fso:operations:layer_id"   = "SecurityService"
  "fso:access_control:security_zone" = "RestrictedZone"
  }
  vpc_id = data.aws_vpc.default.id
}
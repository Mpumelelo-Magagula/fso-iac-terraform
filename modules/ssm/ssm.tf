
resource "aws_secretsmanager_secret" "secret_manager" {
  name = "secret-${var.customer}-${var.environment}-${var.region}"
  recovery_window_in_days = 0
  replica {
    region = "eu-west-1"
}
  tags = {
    "owner" = "tenant"
    Name = "secret-${var.customer}-${var.environment}-${var.region}"
    "fso:operations:environment" = "${var.environment}"
    "fso:cost_control.client_id" = "${var.customer}"
    "fso:governance:tagging_version" = "V1.0"
    "fso:operations:layer_id"   = "SecurityService"
    "fso:access_control:security_zone" = "RestrictedZone"
  }
}



resource "aws_secretsmanager_secret_version" "sversion" {
secret_id = aws_secretsmanager_secret.secret_manager.id
secret_string = <<EOF
{
"region"              : "${var.region}",
"vpclink"             : "vpclink-${var.customer}-${var.environment}-${var.region}",
"vpc"                 : "vpc-${var.customer}-${var.environment}-${var.region}",
"loadbalancer"        : "nlb-${var.vpc}-${var.application}",
"username"            : "admin",
"host"                : "${var.rdsproxy_host}",
"password"            : "${var.dbpass}",
"dbname"              : "csm",
"dbinstanceidentifier": "mysql-${var.customer}-${var.environment}-rds",
"engine"              : "mysql",
"port"                : "3306",
"ecscluster"          : "ecs-${var.customer}-${var.environment}-${var.region}",
"ecswebapiservice"    : "web-api-${var.customer}-${var.environment}-${var.region}",
"ecswebapitaskdefinition" : "web-api-${var.customer}-${var.environment}-${var.region}",
"reponamewebapi"      : "fso-web-api-repo",
"containernamewebapi" : "web-api-${var.customer}-${var.environment}-${var.region}",

"ecsdatamapperservice"    : "data-stream-mapper-${var.customer}-${var.environment}-${var.region}",
"ecsdatamappertaskdefinition" : "data-stream-mapper-${var.customer}-${var.environment}-${var.region}",
"reponamedatamapper"      : "datastream-mapper",
"containernamedatamapper" : "data-stream-mapper-${var.customer}-${var.environment}-${var.region}",

"ecsdataloaderservice"    : "data-stream-loader-${var.customer}-${var.environment}-${var.region}",
"ecsdataloadertaskdefinition" : "data-stream-loader-${var.customer}-${var.environment}-${var.region}",
"reponamedataloader"      : "data-stream-loader",
"containernamedataloader" : "data-stream-loader-${var.customer}-${var.environment}-${var.region}",

"ecsactivationmapperservice"    : "activation-stream-mapper-${var.customer}-${var.environment}-${var.region}",
"ecsactivationmappertaskdefinition" : "activation-stream-mapper-${var.customer}-${var.environment}-${var.region}",
"reponameactivationmapper"      : "activation-stream-mapper",
"containernameactivationmapper" : "activation-stream-mapper-${var.customer}-${var.environment}-${var.region}",

"ecsshareddataservice"    : "shared-data-access-${var.customer}-${var.environment}-${var.region}",
"ecsshareddatataskdefinition" : "shared-data-access-${var.customer}-${var.environment}-${var.region}",
"reponameshareddata"      : "doc-shared-data-access-layer-repo",
"containernameshareddata" : "shared-data-access-${var.customer}-${var.environment}-${var.region}",

"sqsname"             : "${var.customer}-eventbridge-cf-queue"

}
EOF
}

output "ssm-id" {
  value = [
    aws_secretsmanager_secret.secret_manager.name
  ]
}
output "ssm-arn" {
  value = aws_secretsmanager_secret.secret_manager.arn
  
}
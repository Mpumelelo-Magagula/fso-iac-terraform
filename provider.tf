
provider "aws" {
  region = "eu-west-1"
  profile                 = "default"
  shared_config_files = ["~/.aws/config",]
  shared_credentials_files = ["~/.aws/credentials",]

}

terraform {
  backend "s3" {
    bucket = "asi-observability.net"
    key    = "terraform-state"
    region = "us-east-1"

  }
}


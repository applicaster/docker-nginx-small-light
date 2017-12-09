provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn     = "arn:aws:iam::753328315545:role/terraform"
    session_name = "service-images-terraform"
  }
}

data "aws_elb_hosted_zone_id" "main" {}

data "aws_acm_certificate" "star_applicaster_com" {
  domain   = "*.applicaster.com"
  statuses = ["ISSUED"]
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"

  config {
    bucket       = "infra.applicaster.com"
    key          = "terraform/us-east-1.tfstate"
    region       = "${var.region}"
    role_arn     = "arn:aws:iam::753328315545:role/terraform"
    session_name = "service-images-terraform"
  }
}

data "terraform_remote_state" "infrastructure_ng" {
  backend = "s3"

  config {
    bucket       = "infra.applicaster.com"
    key          = "infrastructure-ng/terraform.tfstate"
    region       = "${var.region}"
    role_arn     = "arn:aws:iam::753328315545:role/terraform"
    session_name = "service-images-terraform"
  }
}

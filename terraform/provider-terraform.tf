terraform {
  backend "s3" {
    bucket       = "infra.applicaster.com"
    key          = "terraform/service-images.tfstate"
    region       = "us-east-1"
    role_arn     = "arn:aws:iam::753328315545:role/terraform"
    session_name = "service-images-terraform"
    encrypt      = true
  }
}

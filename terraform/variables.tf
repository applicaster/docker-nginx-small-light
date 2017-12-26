variable "region" {
  default = "us-east-1"
}

variable "coreos_ami" {
  default = "ami-2c393546"
}

variable "docker_env_image_name" {
  default = "applicaster/docker-nginx-small-light:production"
}

variable "docker_env_upstream_base_url" {
  default = "http://s3.amazonaws.com/assets-production.applicaster.com"
}

variable "docker_env_new_relic_license_key" {
  default = "691783c084ea331bef05d91e61f6232207c9d0d6"
}

variable "route53_zone_id_applicaster_com" {
  default = "Z2JBTEMLVLWQEK"
}

variable "aws_key_name" {
  default = "applicaster-052015"
}

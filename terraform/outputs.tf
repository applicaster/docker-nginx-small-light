output "debug1" {
  value = "${data.terraform_remote_state.infrastructure_ng.backstage_vpc_id}"
}

output "debug" {
  value = "${data.terraform_remote_state.infrastructure.aws_key_name}"
}

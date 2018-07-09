# resource "aws_elb" "images_coreos" {
#   name                      = "images-coreos"
#   cross_zone_load_balancing = true

#   security_groups = [
#     "${data.terraform_remote_state.infra.aws_security_group_allow_internal_id}",
#     "${data.terraform_remote_state.infra.aws_security_group_elb_public_id}",
#   ]

#   subnets = [
#     "${data.terraform_remote_state.infra.aws_subnet_elb_us_east_1a_id}",
#     "${data.terraform_remote_state.infra.aws_subnet_elb_us_east_1d_id}",
#   ]

#   listener {
#     instance_port     = 80
#     instance_protocol = "http"
#     lb_port           = 80
#     lb_protocol       = "http"
#   }

#   listener {
#     instance_port      = 80
#     instance_protocol  = "http"
#     lb_port            = 443
#     lb_protocol        = "https"
#     ssl_certificate_id = "${data.aws_acm_certificate.star_applicaster_com.arn}"
#   }

#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 10
#     timeout             = 15
#     target              = "HTTP:80/health"
#     interval            = 300
#   }

#   tags {
#     Name            = "images-coreos"
#     ApplicationName = "images-coreos"
#   }
# }

# resource "aws_route53_record" "origin_images_core_os" {
#   zone_id        = "${var.route53_zone_id_applicaster_com}"
#   name           = "origin-images"
#   type           = "A"
#   set_identifier = "images-coreos"

#   weighted_routing_policy {
#     weight = 100
#   }

#   alias {
#     name                   = "${aws_elb.images_coreos.dns_name}"
#     zone_id                = "${data.aws_elb_hosted_zone_id.main.id}"
#     evaluate_target_health = false
#   }
# }

resource "aws_route53_record" "images" {
  zone_id = "${data.terraform_remote_state.infra.route53_zone_id_applicaster_com}"
  name    = "images"
  type    = "CNAME"
  ttl     = "300"
  allow_overwrite = false
  records = ["images.applicaster.com.edgekey.net"]
}

# data "template_file" "images_coreos_user_data" {
#   template = "${file("templates/images-coreos-user-data.yml.tpl")}"

#   vars {
#     image_name            = "${var.docker_env_image_name}"
#     upstream_base_url     = "${var.docker_env_upstream_base_url}"
#     new_relic_license_key = "${var.docker_env_new_relic_license_key}"
#   }
# }

# resource "aws_launch_configuration" "images_coreos" {
#   name_prefix                 = "images-coreos"
#   image_id                    = "${var.coreos_ami}"
#   instance_type               = "c4.large"
#   key_name                    = "${data.terraform_remote_state.infra.aws_key_name}"
#   associate_public_ip_address = true
#   user_data                   = "${data.template_file.images_coreos_user_data.rendered}"

#   security_groups = [
#     "${data.terraform_remote_state.infra.aws_security_group_allow_internal_id}",
#     "${data.terraform_remote_state.infra.aws_security_group_allow_internet_id}",
#   ]

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_autoscaling_group" "images_coreos" {
#   name                      = "images-coreos"
#   max_size                  = 16
#   min_size                  = 2
#   launch_configuration      = "${aws_launch_configuration.images_coreos.id}"
#   wait_for_capacity_timeout = 0
#   health_check_grace_period = 900
#   health_check_type         = "ELB"
#   load_balancers            = ["${aws_elb.images_coreos.id}"]

#   vpc_zone_identifier = [
#     "${data.terraform_remote_state.infra.aws_subnet_web_us_east_1a_id}",
#     "${data.terraform_remote_state.infra.aws_subnet_web_us_east_1d_id}",
#   ]

#   availability_zones = [
#     "us-east-1a",
#     "us-east-1d",
#   ]

#   enabled_metrics = [
#     "GroupStandbyInstances",
#     "GroupTotalInstances",
#     "GroupPendingInstances",
#     "GroupTerminatingInstances",
#     "GroupDesiredCapacity",
#     "GroupInServiceInstances",
#     "GroupMinSize",
#     "GroupMaxSize",
#   ]

#   tag {
#     key                 = "Name"
#     value               = "images-coreos"
#     propagate_at_launch = true
#   }

#   tag {
#     key                 = "ApplicationName"
#     value               = "images-coreos"
#     propagate_at_launch = true
#   }
# }

# module "images_coreos_cpu_based_autoscaling" {
#   source                 = "github.com/applicaster/terraform-modules//cpu_based_autoscaling?ref=0.0.1"
#   autoscaling_group_name = "${aws_autoscaling_group.images_coreos.name}"

#   scale_out_threshold  = 50
#   scale_out_adjustment = 2

#   scale_in_threshold          = 30
#   scale_in_adjustment         = -2
#   scale_in_period             = 300
#   scale_in_evaluation_periods = 3
# }

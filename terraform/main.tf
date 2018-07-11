
resource "aws_route53_record" "images" {
  zone_id = "${data.terraform_remote_state.infra.route53_zone_id_applicaster_com}"
  name    = "images"
  type    = "CNAME"
  ttl     = "300"
  allow_overwrite = false
  records = ["images.applicaster.com.edgekey.net"]
}
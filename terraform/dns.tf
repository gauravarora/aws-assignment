variable "aws_domain" {}

data "aws_route53_zone" "default" {
    name            = "${var.aws_domain}"
    private_zone    = "false"
}

output "zone_id" {
    value = "${data.aws_route53_zone.default.zone_id}"
}

resource "aws_route53_record" "aws" {
    zone_id = "${data.aws_route53_zone.default.zone_id}"
    name    = "aws.${var.aws_domain}"
    type    = "A"
    alias {
        name                    = "${aws_lb.default.dns_name}"
        zone_id                 = "${aws_lb.default.zone_id}"
        evaluate_target_health  = false
    }
}

resource "aws_route53_record" "cdn" {
    zone_id = "${data.aws_route53_zone.default.zone_id}"
    name    = "cdn.${var.aws_domain}"
    type    = "A"
    alias {
        name                    = "${aws_cloudfront_distribution.default.domain_name}"
        zone_id                 = "${aws_cloudfront_distribution.default.hosted_zone_id}"
        evaluate_target_health  = false
    }
}

resource "aws_route53_record" "linux" {
	zone_id = "${data.aws_route53_zone.default.zone_id}"
	name    = "linux.${var.aws_domain}"
	type    = "A"
	ttl     = "60"
	records = ["${aws_eip.linux.public_ip}"]
}

resource "aws_route53_record" "windows" {
    zone_id = "${data.aws_route53_zone.default.zone_id}"
    name    = "windows.${var.aws_domain}"
    type    = "A"
    ttl     = "60"
    records = ["${aws_eip.windows.public_ip}"]
 }

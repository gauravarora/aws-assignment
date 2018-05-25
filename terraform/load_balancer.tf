resource "aws_lb" "default" {
    name                        = "aws-assignment"
    internal                    = false
    security_groups             = ["${module.http_80.this_security_group_id}", "${module.http_443.this_security_group_id}",  "${module.outgoing.this_security_group_id}"]
    subnets                     = ["${aws_subnet.public_1a.id}", "${aws_subnet.public_1b.id}"]
    enable_deletion_protection  = true
}

resource "aws_lb_target_group" "default" {
    name        = "webservers"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = "${aws_vpc.vpc.id}"
    health_check {
        interval            = 10
        timeout             = 5
        healthy_threshold   = 5
        unhealthy_threshold = 2
    }
}

resource "aws_lb_target_group_attachment" "linux" {
    target_group_arn    = "${aws_lb_target_group.default.arn}"
    target_id           = "${aws_instance.linux.id}"
    port                = 80
}

resource "aws_lb_target_group_attachment" "windows" {
    target_group_arn    = "${aws_lb_target_group.default.arn}"
    target_id           = "${aws_instance.windows.id}"
    port                = 80
}

resource "aws_lb_target_group_attachment" "https_linux" {
    target_group_arn    = "${aws_lb_target_group.default.arn}"
    target_id           = "${aws_instance.linux.id}"
    port                = 80
}
resource "aws_lb_target_group_attachment" "https_windows" {
    target_group_arn    = "${aws_lb_target_group.default.arn}"
    target_id           = "${aws_instance.windows.id}"
    port                = 80
}
resource "aws_lb_listener" "http" {
    load_balancer_arn   = "${aws_lb.default.arn}"
    port                = 80

    default_action {
        target_group_arn    = "${aws_lb_target_group.default.arn}"
        type                = "forward"
    }
}

data "aws_acm_certificate" "default" {
    domain      = "${var.aws_domain}"
    most_recent = true
}

resource "aws_lb_listener" "https" {
    load_balancer_arn   = "${aws_lb.default.arn}"
    port                = 443
    protocol            = "HTTPS"
    ssl_policy          = ""
    certificate_arn     = "${data.aws_acm_certificate.default.arn}"

    default_action {
        target_group_arn    = "${aws_lb_target_group.default.arn}"
        type                = "forward"
    }
 }


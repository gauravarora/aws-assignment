resource "aws_security_group" "ssh" {
    name        = "aws-assignment-ssh"
    description = "ssh allow - managed by terraform"
    vpc_id      = "${aws_vpc.vpc.id}"
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "ssh"
    }
}

module "outgoing" {
    source          = "terraform-aws-modules/security-group/aws"
    name            = "outgoing"
    vpc_id          = "${aws_vpc.vpc.id}"
    egress_rules    = ["all-all"]
}

module "http_80" {
    source                  = "terraform-aws-modules/security-group/aws//modules/http-80"
    name                    = "http-80"
    vpc_id                  = "${aws_vpc.vpc.id}"
    auto_egress_rules       = []
    auto_ingress_with_self  = []
    ingress_cidr_blocks     = ["0.0.0.0/0"]
}

module "http_443" {
    source                  = "terraform-aws-modules/security-group/aws//modules/https-443"
    name                    = "https-443"
    vpc_id                  = "${aws_vpc.vpc.id}"
    auto_egress_rules       = []
    auto_ingress_with_self  = []
    ingress_cidr_blocks     = ["0.0.0.0/0"]
}

module "rdp" {
    source                  = "terraform-aws-modules/security-group/aws//modules/rdp"
    name                    = "rdp"
    vpc_id                  = "${aws_vpc.vpc.id}"
    auto_egress_rules       = []
    auto_ingress_with_self  = []
    ingress_cidr_blocks     = ["0.0.0.0/0"]
}

module "winrm" {
    source                  = "terraform-aws-modules/security-group/aws//modules/winrm"
    name                    = "winrm"
    vpc_id                  = "${aws_vpc.vpc.id}"
    auto_egress_rules       = []
    auto_ingress_with_self  = []
    ingress_cidr_blocks     = ["0.0.0.0/0"]
 }

variable "aws_cdn_cert" {}

resource "aws_cloudfront_origin_access_identity" "default" {
    comment = "cdn distro managed by terraform"
}

resource "aws_cloudfront_distribution" "default" {
    enabled = true
    default_root_object = "index.html"
    aliases = ["cdn.${var.aws_domain}"]
    origin {
        domain_name = "${aws_s3_bucket.default.bucket_domain_name}"
        origin_id   = "s3"
        origin_path = ""
        
        s3_origin_config {
            origin_access_identity = "${aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path}"
        }
    }

    default_cache_behavior {
        allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "s3"
        compress         = "false"

        forwarded_values {
          query_string = "false"

            cookies {
                forward = "none"
            }
        }

        viewer_protocol_policy = "redirect-to-https"
        default_ttl            = 60
        min_ttl                = 0
        max_ttl                = 300
    }

    viewer_certificate {
        acm_certificate_arn            = "${var.aws_cdn_cert}"
        ssl_support_method             = "sni-only"
        minimum_protocol_version       = "TLSv1"
        cloudfront_default_certificate = false
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
            locations        = []
        }
    }
}

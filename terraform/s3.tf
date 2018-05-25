variable "aws_s3_bucket" {}

resource "aws_s3_bucket" "default" {
    bucket = "${var.aws_s3_bucket}.${var.aws_domain}"
    acl = "public-read"
    region = "ap-southeast-1"
    
    website {
        index_document = "index.html"
    }
    versioning {
        enabled = true
    }
}

resource "aws_s3_bucket_object" "index" {
    bucket = "${aws_s3_bucket.default.id}"
    key = "index.html"
    source = "index.html"
    etag   = "${md5(file("index.html"))}"
    content_type = "text/html"
}

resource "aws_s3_bucket_policy" "default" {
  bucket = "${aws_s3_bucket.default.id}"
  policy =<<POLICY
{
  "Version": "2012-10-17",
  "Id": "public-read",
  "Statement": [
    {
      "Sid": "Allow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.default.id}/*"
    }
  ]
}
POLICY
}

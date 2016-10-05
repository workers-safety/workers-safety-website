# ----------------------------------------------
#              THIS MODULE CREATES
#     A PUBLIC S3 BUCKET NAMED WITH A FQND
#     AND THE RECORD ITS RECORD IN ROUTE53
# ----------------------------------------------

variable "subdomain"      { }
variable "fqdn"           { }
variable "route_zone_id"  { }
variable "env"            { }

# CREATES BUCKET

resource "aws_s3_bucket" "website" {
    bucket = "${var.fqdn}"
    //acl = "public-read"
    force_destroy = "true"
    website {
        index_document  = "index.html"
        error_document  = "error.html"
    }

    tags {
        Name            = "${var.fqdn}"
        Env             = "${var.env}"
    }
    policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "S3:GetObject",
      "Resource": "arn:aws:s3:::${var.fqdn}/*"
    }
  ]
}
EOF
}

# CREATES RECORD IN ROUTE53

resource "aws_route53_record" "website" {
  zone_id = "${var.route_zone_id}"
  name    = "${var.subdomain}"
  type    = "A"

  alias{
    name                   = "${aws_s3_bucket.website.website_domain}"
    zone_id                = "${aws_s3_bucket.website.hosted_zone_id}"
    evaluate_target_health = false
  }
}

output "domain"         { value = "${aws_s3_bucket.website.website_domain}" }
output "hosted_zone_id" { value = "${aws_s3_bucket.website.hosted_zone_id}" }
output "endpoint"       { value = "${aws_s3_bucket.website.website_endpoint}" }
output "fqdn"           { value = "${aws_route53_record.website.fqdn}" }


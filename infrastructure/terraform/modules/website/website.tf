# ----------------------------------------------
#              THIS MODULE CREATES
#     A PUBLIC S3 BUCKET NAMED WITH A FQND
#     AND THE RECORD ITS RECORD IN ROUTE53
# ----------------------------------------------

variable "subdomain"      { }
variable "fqdn"           { }
variable "route_zone_id"  { }
variable "env"            { }
variable "anon_actions"   { }

# CREATES BUCKET

// create iam policy for the bucket
data "template_file" "s3_policy" {
    template = "${file("s3_policy.tmpl")}"
    vars {
       anon_actions =  "${var.anon_actions}"
       fqdn = "${var.fqdn}"
    }
}

resource "aws_s3_bucket" "website" {
    bucket = "${var.fqdn}"
    //acl = "public-read"

    cors_rule {
        allowed_headers = ["Authorization"]
        allowed_methods = ["GET"]
        allowed_origins = ["*"]
        max_age_seconds = 3000
    }

    force_destroy = "false"
    website {
        index_document  = "index.html"
        error_document  = "404.html"
    }

    tags {
        Name            = "${var.fqdn}"
        Env             = "${var.env}"
    }
    policy = "${data.template_file.s3_policy.rendered}"
}

# CREATES RECORD IN ROUTE53

resource "aws_route53_record" "website" {
  zone_id = "${var.route_zone_id}"
  name    = "${var.subdomain}"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.website.website_domain}"
    zone_id                = "${aws_s3_bucket.website.hosted_zone_id}"
    evaluate_target_health = false
  }
}

output "domain"         { value = "${aws_s3_bucket.website.website_domain}" }
output "hosted_zone_id" { value = "${aws_s3_bucket.website.hosted_zone_id}" }
output "endpoint"       { value = "${aws_s3_bucket.website.website_endpoint}" }
output "fqdn"           { value = "${aws_route53_record.website.fqdn}" }
output "bucket_name"    { value = "${aws_s3_bucket.website.name}" }

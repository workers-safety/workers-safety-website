# -----------------------------------------------------
#               Global Infrastructure
# -----------------------------------------------------


variable "aws-region"         { default = "us-east-1" }
variable "profile-name"       { default = "default" }
variable "application-name"   { }
variable "domain"             { }
variable "env"

provider "aws" {
  region  = "${var.aws-region}"
  profile = "${var.profile-name}"
}

# CREATE USER TO DEPLOY WEBSITE AND NEWSLETTERS 

module "iam-user" {
  source = "github.com/clamorisse/modular-terraform-automation//modules/iam/users"

  user_names = "${var.application-name}-user,newsletter-user"
}

# POLICY FOR USER DEPLOYING WEBSITE (CIRCLECI)

resource "aws_iam_user_policy" "website-s3-deployment-policy" {
    name = "${var.application-name}-policydeploy"
    user = "${element(split(",", module.iam-user.users), 0)}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
         "arn:aws:s3:::${var.domain}",
         "arn:aws:s3:::stage.${var.domain}"
      ]
    },
    {
      "Action": [
         "s3:PutObject",
         "s3:GetObject",
         "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.domain}/*",
         "arn:aws:s3:::stage.${var.domain}/*"
      ]
    }
  ]
}
EOF
}

# POLICY FOR USER DEPLOYING NEWSLETTERS 

resource "aws_iam_user_policy" "newsletter-s3-deployment-policy" {
    name = "${var.application-name}-policydeploy"
    user = "${element(split(",", module.iam-user.users), 1)}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
         "arn:aws:s3:::newsletter.{var.domain}"
      ]
    },
    {
      "Action": [
         "s3:PutObject",
         "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::newsletter.${var.domain}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_route53_zone" "zone" {
  name = "${var.domain}"
}

module "prod_website" {
  source = "./modules/"

  route_zone_id = "${aws_route53_zone.zone.zone_id}"
  fqdn          = "${var.domain}"
  subdomain     = "${var.domain}"
  env           = "${var.env}"
}

module "stage_website" {
  source = "./modules/"

  route_zone_id = "${aws_route53_zone.zone.zone_id}"
  fqdn          = "stage.${var.domain}"
  subdomain     = "stage"
  env           = "${var.env}"
}

module "newsletter_website" {
  source = "./modules/"
  
  route_zone_id = "${aws_route53_zone.zone.zone_id}"
  fqdn          = "newsletter.${var.domain}"
  subdomain     = "newsletter"
  env           = "${var.env}"
}



# UPLOAD INDEX.HTML FILE TO NEWSLETTER BUCKET 

resource "aws_s3_bucket_object" "object_newsletter" {
    bucket = "${module.newsletter_website.fqdn}"
    key    = "index.html"
    source = "./website_files/index.html"
}


output "users"         { value = "${module.iam-user.users}" }
output "access_ids"    { value = "${module.iam-user.access_ids}" }
output "secret_keys"   { value = "${module.iam-user.secret_keys}" }

output "prod_domain"      { value = "${module.prod_website.domain}" }
output "prod_endpoint"    { value = "${module.prod_website.endpoint}" }
output "prod_fqdn"        { value = "${module.prod_website.fqdn}" }
output "prod_zone_id"     { value = "${module.prod_website.hosted_zone_id}" }

output "stage_domain"   { value = "${module.stage_website.domain}" }
output "stage_endpoint" { value = "${module.stage_website.endpoint}" }
output "stage_fqdn"     { value = "${module.stage_website.fqdn}" }
output "stage_zone_id"  { value = "${module.stage_website.hosted_zone_id}" }

output "zone_id" { value = "${aws_route53_zone.zone.zone_id}" }

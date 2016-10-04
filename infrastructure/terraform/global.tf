# -----------------------------------------------------
#               Global Infrastructure
# -----------------------------------------------------


variable "aws-region"         { default = "us-east-1" }
variable "profile-name"       { default = "default" }
variable "application-name"   { }
variable "bucket-prod"          { }
variable "bucket-stage"         { }
variable "file-bucket"          { }

provider "aws" {
  region  = "${var.aws-region}"
  profile = "${var.profile-name}"
}

# CREATE USER TO DEPLOY WEBSITE AND NEWSLETTERS 

module "iam-user" {
  source = "github.com/clamorisse/modular-terraform-automation//modules/iam/users"

  user_names = "${var.application-name}-user,newsletter-user"
}

# POLICY FOR DEPLOYING WEBSITE (CIRCLECI)

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
         "arn:aws:s3:::${var.bucket-prod}",
         "arn:aws:s3:::${var.bucket-stage}"
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
         "arn:aws:s3:::${var.bucket-prod}/*",
         "arn:aws:s3:::${var.bucket-stage}/*"
      ]
    }
  ]
}
EOF
}

# POLICY FOR DEPLOYING NEWSLETTERS 

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
         "arn:aws:s3:::${var.bucket-prod}",
         "arn:aws:s3:::${var.bucket-stage}"
      ]
    },
    {
      "Action": [
         "s3:PutObject",
         "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.bucket-prod}/*",
         "arn:aws:s3:::${var.bucket-stage}/*"
      ]
    }
  ]
}
EOF
}


# CREATE BUCKET FOR NEWSLETTERS 

resource "aws_s3_bucket" "newsletters-bucket" {
    bucket = "${var.file-bucket}"
    //acl = "public-read"
    force_destroy = "true"
    policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "S3:GetObject",
      "Resource": "arn:aws:s3:::${var.file-bucket}/*"
    }
  ]
}
EOF
}

output "users"         { value = "${module.iam-user.users}" }
output "access_ids"    { value = "${module.iam-user.access_ids}" }
output "secret_keys"   { value = "${module.iam-user.secret_keys}" }


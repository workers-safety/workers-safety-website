# -----------------------------------------------------
#               Global Infrastructure
# -----------------------------------------------------


variable "aws-region"         { default = "us-east-1" }
variable "profile-name"       { default = "default" }
variable "application-name"   { }
variable "bucket-prod"          { }
variable "bucket-stage"         { }
variable "file-bucket-prod"     { }
variable "file-bucket-stage"    { }

provider "aws" {
  region  = "${var.aws-region}"
  profile = "${var.profile-name}"
}

# CREATE USER TO DEPLOY BLOG

module "iam-user" {
  source = "github.com/clamorisse/modular-terraform-automation//modules/iam/users"

  user_names = "${var.application-name}-user"
}

resource "aws_iam_user_policy" "blog-s3-deployment-policy" {
    name = "${var.application-name}-policydeploy"
    user = "${module.iam-user.users}"
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
         "arn:aws:s3:::${var.bucket-stage}",
         "arn:aws:s3:::${var.file-bucket-prod}",
         "arn:aws:s3:::${var.file-bucket-stage}"
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
         "arn:aws:s3:::${var.bucket-stage}/*",
         "arn:aws:s3:::${var.file-bucket-prod}",
         "arn:aws:s3:::${var.file-bucket-stage}"
      ]
    }
  ]
}
EOF
}

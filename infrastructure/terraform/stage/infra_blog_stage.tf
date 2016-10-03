# -----------------------------------------------
#       GLOBAL INFRASTRUCTURE FOR BLOG
#                 HOSTED IN S3
#               STAGE ENVIRONMENT
# ----------------------------------------------


variable "application-name"    { }
variable "bucket-name"         { }
variable "env"                 { }
variable "file-bucket"         { }

# CREATE BUCKET IN S3

resource "aws_s3_bucket" "blog-bucket" {
    bucket = "${var.bucket-name}"
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
      "Resource": "arn:aws:s3:::${var.bucket-name}/*"
    }
  ]
}
EOF

    website {
        index_document  = "index.html"
        error_document  = "error.html"
    }

    tags {
        Name            = "${var.bucket-name}"
        Env             = "${var.env}"
    }
}


# CREATE BUCKET FOR WEBSITE FILES

resource "aws_s3_bucket" "website-files-bucket" {
    bucket = "${var.file-bucket}-${var.env}"
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
      "Resource": "arn:aws:s3:::${var.file-bucket}-${var.env}/*"
    }
  ]
}
EOF
}


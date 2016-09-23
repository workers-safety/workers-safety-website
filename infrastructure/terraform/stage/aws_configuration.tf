# ---------------------------------------------------
#               Configuration of AWS
#               Account and Profile
#           Terraform remote state in S3
# --------------------------------------------------

variable "aws-region"         { default = "us-east-1" }
variable "profile-name"       { default = "default" }


provider "aws" {
  region  = "${var.aws-region}"
  profile = "${var.profile-name}"
}


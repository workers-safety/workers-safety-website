# ---------------------------------------------------
#               Configuration of AWS
#               Account and Profile
#           Terraform remote state in S3
# --------------------------------------------------

variable "aws-region"         { default = "us-east-1" }
variable "profile-name"       { default = "default" }


# profile-name is the name of the profile to be used from file ~/.aws/credentials

provider "aws" {
  region  = "${var.aws-region}"
  profile = "${var.profile-name}"
}


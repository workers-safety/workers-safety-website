# --------------------------------------------------
#  Module to create an AWS IAM users and keys
# --------------------------------------------------

variable "user_names"  { }

resource "aws_iam_user" "user" {
  count = "${length(split(",", var.user_names))}"
  name  = "${element(split(",", var.user_names), count.index)}"
}

resource "aws_iam_access_key" "key" {
  count = "${length(split(",", var.user_names))}"
  user  = "${element(aws_iam_user.user.*.name, count.index)}"
}

output "users"       { value = "${join(",", aws_iam_access_key.key.*.user)}" }
output "access_ids"  { value = "${join(",", aws_iam_access_key.key.*.id)}" }
output "secret_keys" { value = "${join(",", aws_iam_access_key.key.*.secret)}" }

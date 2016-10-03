# ---------------------------------------------------
#         VARIABLES FOR ALL .TF FILES
# ---------------------------------------------------

# AWS CONFIGURATION VARIABLES

aws-region           = "us-east-1"
profile-name         = "workers-bvc-admin"

# TERRAFORM REMOTE STATE CONFIGURATION VARIABLES

tfstate-bucket       = "tfstate_blog_infra"
object-name          = "terraform.tfstate"

// app specific variables for production - be careful

application-name    = "workers_site" 
bucket-name         = "stage.workers-safety.ca"
file-bucket         = "workers-files"
env                 = "stage" 

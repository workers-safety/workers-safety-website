[![CircleCI](https://circleci.com/gh/workers-safety/workers-safety-website.svg?style=svg)](https://circleci.com/gh/workers-safety/workers-safety-website)

# Website Automation
## For Workers' Health and Safety Legal Clinic

This repository is used to manage a static website hosted in AWS S3.

The basic infrastructure needed to deploy the website is generated using Terraform found in ```infrastructure/terraform/``` and is tested using rspec. This part is done manually.

The website is generated using a docker cointainer for Hugo that is tested and deployed using CircleCI.

The website section in this repository can be further managed using [forestry.io](http://forestry.io) to easily generate content using a markdown editor.

The tools used are: terraform, rspec, docker, gohugo and amazon cli.

# Instructions to manage this repository manually

## Infrastructure

Terraform is used to create the necessary resources in AWS: user for CircleCI, production and stage S3 buckets, a bucket for the Newsletters, Route53 zone and records.
A separate terraform plan is use to create a S3 bucket with version control to store the terraform state.

### Remote configuration state for terraform.

Make sure you have AWS configured with a file ```~/.aws/credentials```:
```
[name-of-profile]
aws_access_key_id = xxxxxxxx
aws_secret_access_key = xxxxxxxx
```
To create bucket for terrafrom remote state go to ```infrastructure/terraform/tfstate-bucket/``` and run
```
terraform plan
terraform apply
```
Then go to the directory ```infrastructure/terraform/global/``` and modify ```terraform.tfvars``` files to have the name of the AWS profile you want to use. Then run the script to configure the remote state:
```
. ./tfstate_remote_global.sh
```

### Deploying infrastructure with terraform:

Now you can change the ```.tf``` and ```.tfvars```, plan and apply changes:
```
terraform plan
terraform apply
```

## Building docker gohugo image
### This repository builds and deploys automatically using CircleCI.

To build image, run following command in the ```docker-hugo-site``` directory.
```
docker build -t clamorisse/hugo:0.15 .
```

## Website: development and publishing

To work with the site content, get to the repository root directory.

For development, run docker with these options:
```
docker run -d -p 1313:1313 --name hugotest -v $(pwd)/:/usr/src/blog clamorisse/hugo:0.15 hugo server --baseUrl=http//localhost/ --watch --bind=0.0.0.0
```

To publish changes manually run this commands:
```
docker run -v $(pwd)/:/usr/src/blog clamorisse/hugo:0.15 hugo --baseUrl=http://baseUrl/
docker run -d -p 1313:1313 --name hugoprod -v $(pwd)/:/usr/src/blog clamorisse/hugo:0.15 hugo server --baseUrl=http://baseUrl/ --appendPort=false --bind=0.0.0.0
aws s3 rm s3://workers-safety.ca/ --recursive
aws s3 sync public/ s3://bucket-name/
aws s3 sync newsletter-list/publico/ s3://newsletter-bucket-name
```


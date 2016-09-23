#!bin/bash
# BASH version 4.3.46(1)-release

# Script to set up terraform remote state 

echo "Reading and Exporting environmental variables"
echo " "

path=$PWD

# Extract bootstrap bucket from tfstate output
cd ../tfstate-bucket # Bootstrap folder to create bucket for remote tfstate
bucket=$(terraform output | awk '{print$3}')
cd $path 

# Extracting variables from tfvars file
 
region=$(grep "aws-region" ./terraform.tfvars | awk '{print$3}')
profile=$(grep "profile-name" ./terraform.tfvars | awk '{print$3}')
#bucket=$(terraform output -state=tfstate-bucket/terraform.tfstate | awk '{print$3}')
filename=$(grep "object-name" ./terraform.tfvars | awk '{print$3}')
appname=$(grep "application-name" ./terraform.tfvars | awk '{print$3}')
environment=$(grep "env" ./terraform.tfvars | awk '{print$3}')

# Cleaning format of variables

export AWS_REGION="${region:1:-1}"
export AWS_PROFILE="${profile:1:-1}"
export TFSTATE_BUCKET="$bucket"
export TFSTATE_FILE="${filename:1:-1}"
export APP="${appname:1:-1}"
export TF_ENV="${environment:1:-1}"

echo "aws-region: $AWS_REGION"
echo "profile: $AWS_PROFILE"
echo "bucket: $TFSTATE_BUCKET"
echo "key: $APP/$TF_ENV/$TFSTATE_FILE"
echo " "

echo "Reading AWS credential form $AWS_PROFILE"
echo " "
# Print profile line from credetials file

sed -n "/"$AWS_PROFILE"/p" ~/.aws/credentials

# Print access-key-id

sed -n "$(sed -n "/"$AWS_PROFILE"/=" ~/.aws/credentials | awk '{ SUM = $1+1} END { print SUM }')p" ~/.aws/credentials | awk '{print$1}'
export ACCESS_KEY=$(sed -n "$(sed -n "/"$AWS_PROFILE"/=" ~/.aws/credentials | awk '{ SUM = $1+1} END { print SUM }')p" ~/.aws/credentials | awk '{print$3}')
echo $ACCESS_KEY

# Print secret-access-key-id

# Print access-key-id

sed -n "$(sed -n "/"$AWS_PROFILE"/=" ~/.aws/credentials | awk '{ SUM = $1+2} END { print SUM }')p" ~/.aws/credentials | awk '{print$1}'
export SECRET_KEY=$(sed -n "$(sed -n "/"$AWS_PROFILE"/=" ~/.aws/credentials | awk '{ SUM = $1+2} END { print SUM }')p" ~/.aws/credentials | awk '{print$3}')
echo $SECRET_KEY
echo " "

echo "LETS CONFIGURE TERRAFORM REMOTE STATE"
echo "Do you want to continue with this configuration?"
echo " "
echo "terraform remote config \ "
echo "    -backend=s3 \ "
echo "    -backend-config="bucket=$TFSTATE_BUCKET" \ "
echo "    -backend-config="key=$APP/$TF_ENV/$TFSTATE_FILE" \ "
echo "    -backend-config="region=$AWS_REGION" \ "
echo "    -backend-config="access_key=$ACCESS_KEY" \ "
echo "    -backend-config="secret_key=$SECRET_KEY""
echo "(y/n)"

read answer

if [[ "$answer" == "n" ]]; then
    echo "All this work to the sink...boo!"
    return
  else
    echo "Here we go..."
    terraform remote config \
      -backend=s3 \
      -backend-config="bucket=$TFSTATE_BUCKET" \
      -backend-config="key=$APP/$TF_ENV/$TFSTATE_FILE" \
      -backend-config="region=$AWS_REGION" \
      -backend-config="access_key=$ACCESS_KEY" \
      -backend-config="secret_key=$SECRET_KEY"
    echo " "
    echo "aws s3 ls s3://$TFSTATE_BUCKET --recursive"
    aws s3 ls s3://$TFSTATE_BUCKET --recursive
    echo " "
    echo "voilà...c'est fini!"
fi

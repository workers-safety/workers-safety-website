require 'spec_helper'

describe s3_bucket('clamorisse-blog') do
  it { should exist }
  its(:acl_owner) { should eq 'blah' }
  its(:acl_grants_count) { should eq 1 }
  it do 
    should have_acl_grant(grantee: 'bls', permission: 'FULL_CONTROL')
  end

  it do
    should have_policy <<-POLICY
    {
   	"Version": "2012-10-17",
   	"Statement": [
   	 {
   	   "Sid": "AddPerm",
   	   "Effect": "Allow",
   	   "Principal": "*",
   	   "Action": "s3:GetObject",
   	   "Resource": "arn:aws:s3:::clamorisse-blog/*"
         }
         ]
    }  
   POLICY
  end

  it { should have_object('robots.txt') }
  it { should have_object('index.html') }
end

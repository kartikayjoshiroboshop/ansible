#! /bin/bash

# 1. Create an spot instance
# 2. Take the instance ip and register in DNS

TEMP_ID="lt-060b9b29cc136a449"
TEMP_VER=1

# Check if instance is already there
aws ec2 run-instances --launch-template LaunchTemplateId=${TEMP_ID},Version={TEMP_VER} --tag-specification "ResourceType=instances,Tags=[{Key=Name,Value=frontend}]"  "ResourceType=spot-instance-request,Tags=[{Key=Name,Value=frontend}]" | jq

# Updated DNS record


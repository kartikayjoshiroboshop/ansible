#! /bin/bash

# 1. Create an spot instance
# 2. Take the instance ip and register in DNS

if [ -z "$1" ]; then
  echo -e "\e[1;31mInput is missing\e[0m"
  exit 1
fi

COMPONENT=$1


TEMP_ID="lt-060b9b29cc136a449"
TEMP_VER=1
ZONE_ID=Z03176063U3033ZBJYXA7

CREATE_INSTANCE() {
# Check if instance is already there if not create one

aws ec2 describe-instance --filters "Name=tag:Name,Values=${COMPONENT}" | jq .Reservations[].Instances[].State.Name | sed 's/"//g' | grep - E 'running|stopped' &>/dev/null
if [ $? -eq -0 ]; then
  echo "\e[1;33mInstance is already there\e[0m"
else
  aws ec2 run-instances --launch-template LaunchTemplateId=${TEMP_ID},Version=${TEMP_VER} --tag-specification "ResourceType=instances,Tags=[{Key=Name,Value=${COMPONENT}}]"  "ResourceType=spot-instance-request,Tags=[{Key=Name,Value=${COMPONENT}}]" | jq
fi


sleep 10

IPADDRESS=$(aws ec2 describe-instance --filters "Name=tag:Name,Values=frontend" | jq .Reservations[].Instances[].PrivateIPAddress | sed 's/"//g' | grep -v  null)

# Update the DNS record
  sed -e "s/IPADDRESS/${IPADDRESS}/" -e "s/COMPONENT/${COMPONENT}/" record.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json | jq


}

if [ "$COMPONENT" == "all" ] ; then
  for comp in frontend mongodb catalouge; do
    COMPONENT=$comp
    CREATE_INSTANCE
  done
else
   CREATE_INSTANCE
fi





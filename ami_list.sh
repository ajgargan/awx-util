#!/bin/sh

for reg in $(aws ec2 describe-regions | jq -r ".|.Regions[]|.RegionName")
do
  echo $reg
  aws ec2 describe-images --region $reg --filters "Name=description,Values='CentOS Linux 7*'" "Name=owner-id,Values=679593333241" | \
  jq -s ".|.[]|.[]|sort_by(.CreationDate)|.[-1]|.Name,.CreationDate,.Description,.ImageId,.OwnerId"
done

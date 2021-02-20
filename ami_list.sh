#!/bin/sh

for reg in $(aws ec2 describe-regions | jq -r ".|.Regions[]|.RegionName")
do
  echo $reg
  aws ec2 describe-images --region $reg --filters "Name=description,Values='CentOS Linux 7*'" "Name=owner-id,Values=679593333241" | \
  jq -s ".|.[]|.[]|sort_by(.CreationDate)|.[-1]|.Name,.CreationDate,.Description,.ImageId,.OwnerId"
done


for region in `aws ec2 describe-regions | jq -r ".|.Regions[]|.RegionName"`;
do    
  echo "    $region:"
  echo -n "      CENTOS7: "
  aws --region $region ec2 describe-images --owners aws-marketplace --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce|jq -r ".|.[]|sort_by(.CreationDate)|reverse|.[0]|.ImageId"
done

#!/bin/bash

regions=$(aws ec2 describe-regions --query "Regions[*].RegionName" --output text)

for region in $regions; do
  echo "=============================="
  echo "Region: $region"
  echo "=============================="

  echo "-- Terminating EC2 Instances --"
  instances=$(aws ec2 describe-instances --region $region --query "Reservations[*].Instances[*].InstanceId" --output text)
  [[ -n "$instances" ]] && aws ec2 terminate-instances --instance-ids $instances --region $region

  echo "-- Deleting EBS Volumes --"
  volumes=$(aws ec2 describe-volumes --region $region --query "Volumes[*].VolumeId" --output text)
  [[ -n "$volumes" ]] && for id in $volumes; do aws ec2 delete-volume --volume-id $id --region $region; done

  echo "-- Releasing Elastic IPs --"
  allocation_ids=$(aws ec2 describe-addresses --region $region --query "Addresses[*].AllocationId" --output text)
  [[ -n "$allocation_ids" ]] && for id in $allocation_ids; do aws ec2 release-address --allocation-id $id --region $region; done

  echo "-- Deleting Snapshots (Owned) --"
  snapshots=$(aws ec2 describe-snapshots --owner-ids self --region $region --query "Snapshots[*].SnapshotId" --output text)
  [[ -n "$snapshots" ]] && for id in $snapshots; do aws ec2 delete-snapshot --snapshot-id $id --region $region; done

  echo "-- Deregistering AMIs (Owned) --"
  images=$(aws ec2 describe-images --owners self --region $region --query "Images[*].ImageId" --output text)
  [[ -n "$images" ]] && for id in $images; do aws ec2 deregister-image --image-id $id --region $region; done

  echo "-- Deleting Launch Templates --"
  templates=$(aws ec2 describe-launch-templates --region $region --query "LaunchTemplates[*].LaunchTemplateId" --output text)
  [[ -n "$templates" ]] && for id in $templates; do aws ec2 delete-launch-template --launch-template-id $id --region $region; done

  echo "-- Deleting Auto Scaling Groups --"
  asgs=$(aws autoscaling describe-auto-scaling-groups --region $region --query "AutoScalingGroups[*].AutoScalingGroupName" --output text)
  [[ -n "$asgs" ]] && for id in $asgs; do aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $id --region $region --force-delete; done

  echo "-- Deleting Classic Load Balancers --"
  clbs=$(aws elb describe-load-balancers --region $region --query "LoadBalancerDescriptions[*].LoadBalancerName" --output text 2>/dev/null)
  [[ -n "$clbs" ]] && for id in $clbs; do aws elb delete-load-balancer --load-balancer-name $id --region $region; done

  echo "-- Deleting ALBs/NLBs --"
  elbs=$(aws elbv2 describe-load-balancers --region $region --query "LoadBalancers[*].LoadBalancerArn" --output text 2>/dev/null)
  [[ -n "$elbs" ]] && for id in $elbs; do aws elbv2 delete-load-balancer --load-balancer-arn $id --region $region; done

  echo "-- Deleting Security Groups --"
  sgs=$(aws ec2 describe-security-groups --region $region --query "SecurityGroups[?GroupName!='default'].[GroupId]" --output text)
  [[ -n "$sgs" ]] && for id in $sgs; do aws ec2 delete-security-group --group-id $id --region $region; done

done

echo "✅ All EC2-related resources deleted across all regions."
